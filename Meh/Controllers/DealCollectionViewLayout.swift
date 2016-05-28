//
//  DealCollectionViewLayout.swift
//  Meh
//
//  Created by Bradley Smith on 3/3/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol DealCollectionViewLayoutDelegate: NSObjectProtocol {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath,
        withWidth width: CGFloat) -> CGFloat
    func collectionView(collectionView: UICollectionView,
        heightForSupplementaryViewOfKind kind: String, atIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class DealCollectionViewLayout: UICollectionViewLayout {
    static let photosHeaderElementKind = "photos_header_element_kind"
    static let buyHeaderElementKind = "buy_header_element_kind"
    static let footerElementKind = "footer_element_kind"

    private lazy var itemLayoutAttributesCache = [UICollectionViewLayoutAttributes]()

    private var photosHeaderLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.photosHeaderElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var buyHeaderLayoutAttributes = HeaderCollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.buyHeaderElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var footerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.footerElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat  = 0.0

    weak var delegate: DealCollectionViewLayoutDelegate?

    var pinnedBuyHeaderOffset: CGFloat = 0.0

    override class func layoutAttributesClass() -> AnyClass {
        return HeaderCollectionViewLayoutAttributes.self
    }

    override func prepareLayout() {
        if let collectionView = collectionView {
            contentWidth = collectionView.bounds.width

            let sectionCount = collectionView.numberOfSections()

            if sectionCount > 0 {
                let section = 0
                let xOffset: CGFloat = 0.0
                var yOffset: CGFloat = 0.0
                var indexPath = NSIndexPath(forItem: 0, inSection: 0)

                //configure photos supplementary view
                var photosHeight: CGFloat = 0.0
                if let delegate = delegate {
                    photosHeight = delegate.collectionView(collectionView, heightForSupplementaryViewOfKind: DealCollectionViewLayout.photosHeaderElementKind, atIndexPath: indexPath, withWidth: contentWidth)
                }

                var frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: photosHeight)
                photosHeaderLayoutAttributes.frame = frame
                photosHeaderLayoutAttributes.zIndex = 0

                //configure button supplementary view
                var buttonHeight: CGFloat = 0.0
                if let delegate = delegate {
                    buttonHeight = delegate.collectionView(collectionView, heightForSupplementaryViewOfKind: DealCollectionViewLayout.buyHeaderElementKind, atIndexPath: indexPath, withWidth: contentWidth)
                }

                yOffset += (collectionView.bounds.height - buttonHeight)

                frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: buttonHeight)
                buyHeaderLayoutAttributes.frame = frame
                buyHeaderLayoutAttributes.zIndex = 2

                yOffset = buyHeaderLayoutAttributes.frame.maxY

                //configure items
                for item in 0 ..< collectionView.numberOfItemsInSection(section) {
                    indexPath = NSIndexPath(forItem: item, inSection: section)

                    var itemHeight: CGFloat = 0.0
                    if let delegate = delegate {
                        itemHeight = delegate.collectionView(collectionView, heightForItemAtIndexPath: indexPath, withWidth: contentWidth)
                    }

                    frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: itemHeight)
                    let itemLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                    itemLayoutAttributes.frame = frame
                    itemLayoutAttributes.zIndex = 1
                    itemLayoutAttributesCache.append(itemLayoutAttributes)

                    yOffset = frame.maxY
                }

                //configure footer supplementary view
                frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: 0.0)
                footerLayoutAttributes.frame = frame
                footerLayoutAttributes.zIndex = 1

                contentHeight = yOffset
            }
        }
    }

    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        if let collectionView = collectionView {
            if collectionView.numberOfSections() > 0 {
                var allLayoutAttributes = itemLayoutAttributesCache
                allLayoutAttributes.append(photosHeaderLayoutAttributes)
                allLayoutAttributes.append(buyHeaderLayoutAttributes)
                allLayoutAttributes.append(footerLayoutAttributes)

                for attributes in allLayoutAttributes {
                    if CGRectIntersectsRect(attributes.frame, rect) {
                        layoutAttributes.append(attributes)
                    }
                }
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == DealCollectionViewLayout.photosHeaderElementKind {
            if let collectionView = collectionView {
                photosHeaderLayoutAttributes.frame.origin.y = collectionView.contentOffset.y

                let modifier: CGFloat = 2.0
                let value = (min(collectionView.contentOffset.y, photosHeaderLayoutAttributes.frame.height) * modifier) / photosHeaderLayoutAttributes.frame.height
                let alpha = min(1, 1 - value)
                photosHeaderLayoutAttributes.alpha = alpha
            }

            return photosHeaderLayoutAttributes
        }
        else if elementKind == DealCollectionViewLayout.buyHeaderElementKind {
            if let collectionView = collectionView {
                buyHeaderLayoutAttributes.frame = buyHeaderFrameForContentOffset(collectionView.contentOffset)
            }

            return buyHeaderLayoutAttributes
        }
        else if elementKind == DealCollectionViewLayout.footerElementKind {
            footerLayoutAttributes.frame = footerFrame()

            return footerLayoutAttributes
        }
        else {
            return nil
        }
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.item < itemLayoutAttributesCache.count {
            return itemLayoutAttributesCache[indexPath.item]
        }
        else {
            return nil
        }
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        invalidateLayoutWithContext(invalidationContextForBoundsChange(newBounds))

        return super.shouldInvalidateLayoutForBoundsChange(newBounds)
    }

    override func invalidationContextForBoundsChange(newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context: UICollectionViewLayoutInvalidationContext = super.invalidationContextForBoundsChange(newBounds)

        if let collectionView = collectionView {
            if collectionView.numberOfSections() > 0 {
                let indexPath: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
                context.invalidateSupplementaryElementsOfKind(DealCollectionViewLayout.photosHeaderElementKind, atIndexPaths: [indexPath])
                context.invalidateSupplementaryElementsOfKind(DealCollectionViewLayout.buyHeaderElementKind, atIndexPaths: [indexPath])
                context.invalidateSupplementaryElementsOfKind(DealCollectionViewLayout.footerElementKind, atIndexPaths: [indexPath])
            }
        }

        return context
    }

    override func invalidateLayout() {
        itemLayoutAttributesCache.removeAll()

        contentWidth = 0.0
        contentHeight = 0.0

        super.invalidateLayout()
    }
}

// MARK: - Private

private extension DealCollectionViewLayout {
    func buyHeaderFrameForContentOffset(contentOffset: CGPoint) -> CGRect {
        var frame = buyHeaderLayoutAttributes.frame

        if contentOffset.y > (collectionView!.bounds.height - frame.height) {
            frame.origin.y = contentOffset.y
            buyHeaderLayoutAttributes.isPinned = true
        }
        else {
            frame.origin.y = collectionView!.bounds.height - frame.height
            buyHeaderLayoutAttributes.isPinned = false
        }

        return frame
    }

    func footerFrame() -> CGRect {
        var frame: CGRect = .zero

        if let collectionView = collectionView {
            let threshold = collectionView.contentOffset.y + collectionView.bounds.height
            let height = max(0.0, threshold - contentHeight)

            frame = CGRect(x: 0.0, y: contentHeight, width: contentWidth, height: height)
        }

        return frame
    }
}
