//
//  DealCollectionViewLayout.swift
//  Meh
//
//  Created by Bradley Smith on 3/3/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol DealCollectionViewLayoutDelegate: NSObjectProtocol {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath, width: CGFloat) -> CGFloat
    func collectionView(collectionView: UICollectionView, sizeForSupplementaryViewOfKind kind: String, width: CGFloat) -> CGSize
}

class DealCollectionViewLayout: UICollectionViewLayout {
    static let photosHeaderElementKind = "photos_header_element_kind"
    static let titleHeaderElementKind = "title_header_element_kind"
    static let buyHeaderElementKind = "buy_header_element_kind"
    static let footerElementKind = "footer_element_kind"

    private lazy var itemLayoutAttributesCache = [UICollectionViewLayoutAttributes]()

    private var photosHeaderLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.photosHeaderElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var titleHeaderLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.titleHeaderElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var buyHeaderLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.buyHeaderElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var footerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.footerElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat  = 0.0

    weak var delegate: DealCollectionViewLayoutDelegate?

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
                let photosHeight = delegate?.collectionView(collectionView, sizeForSupplementaryViewOfKind: DealCollectionViewLayout.photosHeaderElementKind, width: contentWidth).height ?? 0.0

                var frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: photosHeight)
                photosHeaderLayoutAttributes.frame = frame
                photosHeaderLayoutAttributes.zIndex = 0

                //configure title supplementary view
                let titleHeight = delegate?.collectionView(collectionView, sizeForSupplementaryViewOfKind: DealCollectionViewLayout.titleHeaderElementKind, width: contentWidth).height ?? 0.0

                yOffset += (collectionView.bounds.height - titleHeight)

                frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: titleHeight)
                titleHeaderLayoutAttributes.frame = frame
                titleHeaderLayoutAttributes.zIndex = 2

                yOffset = titleHeaderLayoutAttributes.frame.maxY

                //configure buy supplementary view
                let buySize = delegate?.collectionView(collectionView, sizeForSupplementaryViewOfKind: DealCollectionViewLayout.buyHeaderElementKind, width: contentWidth) ?? .zero

                let x = contentWidth - 20.0 - buySize.width
                let y = collectionView.bounds.height - 20.0 - buySize.height

                frame = CGRect(x: x, y: y, width: buySize.width, height: buySize.height)
                buyHeaderLayoutAttributes.frame = frame
                buyHeaderLayoutAttributes.zIndex = 3

                //configure items
                for item in 0 ..< collectionView.numberOfItemsInSection(section) {
                    indexPath = NSIndexPath(forItem: item, inSection: section)

                    let itemHeight = delegate?.collectionView(collectionView, heightForItemAtIndexPath: indexPath, width: contentWidth) ?? 0.0

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
                allLayoutAttributes.append(titleHeaderLayoutAttributes)
                allLayoutAttributes.append(buyHeaderLayoutAttributes)
                allLayoutAttributes.append(footerLayoutAttributes)

                let attributes = allLayoutAttributes.filter({$0.frame.intersects(rect)})
                layoutAttributes.appendContentsOf(attributes)
            }
        }

        return layoutAttributes
    }

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case DealCollectionViewLayout.photosHeaderElementKind:
            if let collectionView = collectionView {
                photosHeaderLayoutAttributes.frame = photoHeaderFrameForContentOffset(collectionView.contentOffset)
            }

            return photosHeaderLayoutAttributes
        case DealCollectionViewLayout.titleHeaderElementKind:
            if let collectionView = collectionView {
                titleHeaderLayoutAttributes.frame = titleHeaderFrameForContentOffset(collectionView.contentOffset)
            }

            return titleHeaderLayoutAttributes
        case DealCollectionViewLayout.buyHeaderElementKind:
            if let collectionView = collectionView {
                buyHeaderLayoutAttributes.frame = buyHeaderFrameForContentOffset(collectionView.contentOffset)
            }

            return buyHeaderLayoutAttributes
        case DealCollectionViewLayout.footerElementKind:
            footerLayoutAttributes.frame = footerFrame()

            return footerLayoutAttributes
        default:
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
                let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                context.invalidateSupplementaryElementsOfKind(DealCollectionViewLayout.photosHeaderElementKind, atIndexPaths: [indexPath])
                context.invalidateSupplementaryElementsOfKind(DealCollectionViewLayout.titleHeaderElementKind, atIndexPaths: [indexPath])
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
    func photoHeaderFrameForContentOffset(contentOffset: CGPoint) -> CGRect {
        var frame = photosHeaderLayoutAttributes.frame

        let titleHeaderFrame = titleHeaderFrameForContentOffset(contentOffset)

        if contentOffset.y + frame.height < titleHeaderFrame.minY {
            frame.origin.y = contentOffset.y
        }
        else {
            frame.origin.y = titleHeaderFrame.minY - frame.height
        }

        return frame
    }

    func titleHeaderFrameForContentOffset(contentOffset: CGPoint) -> CGRect {
        var frame = titleHeaderLayoutAttributes.frame

        guard let collectionView = collectionView else {
            return frame
        }

        if contentOffset.y > (collectionView.bounds.height - frame.height) {
            frame.origin.y = contentOffset.y
        }
        else {
            frame.origin.y = collectionView.bounds.height - frame.height
        }

        return frame
    }

    func buyHeaderFrameForContentOffset(contentOffset: CGPoint) -> CGRect {
        var frame = buyHeaderLayoutAttributes.frame

        guard let collectionView = collectionView else {
            return frame
        }

        let value = (contentOffset.y + collectionView.bounds.height) - 20.0 - frame.height
        let titleHeaderFrame = titleHeaderFrameForContentOffset(contentOffset)
        let otherValue = titleHeaderFrame.maxY - (frame.height / 2.0)

        frame.origin.y = min(value, otherValue)

        return frame
    }

    func footerFrame() -> CGRect {
        var frame: CGRect = .zero

        guard let collectionView = collectionView else {
            return frame
        }

        let threshold = collectionView.contentOffset.y + collectionView.bounds.height
        let height = max(0.0, threshold - contentHeight)

        frame = CGRect(x: 0.0, y: contentHeight, width: contentWidth, height: height)

        return frame
    }
}
