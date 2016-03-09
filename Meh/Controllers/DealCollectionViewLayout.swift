//
//  DealCollectionViewLayout.swift
//  Meh
//
//  Created by Bradley Smith on 3/3/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol DealCollectionViewLayoutDelegate: class {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath,
        withWidth width: CGFloat) -> CGFloat
    func collectionView(collectionView: UICollectionView,
        heightForSupplementaryViewOfKind kind: String, atIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
}

class DealCollectionViewLayout: UICollectionViewLayout {

    // MARK: Properties

    static let infoHeaderElementKind = "info_header_element_kind"
    static let buttonHeaderElementKind = "button_header_element_kind"
    static let footerElementKind = "footer_element_kind"

    var delegate: DealCollectionViewLayoutDelegate?
    var pinnedBuyHeaderOffset: CGFloat = 0.0

    private lazy var itemLayoutAttributesCache = [UICollectionViewLayoutAttributes]()

    private var infoHeaderLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.infoHeaderElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var buttonHeaderLayoutAttributes = HeaderCollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.buttonHeaderElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var footerLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: DealCollectionViewLayout.footerElementKind, withIndexPath: NSIndexPath(forItem: 0, inSection: 0))
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat  = 0.0

    // MARK: Lifecycle

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

                //configure info supplementary view
                var infoHeight: CGFloat = 0.0
                if let delegate = delegate {
                    infoHeight = delegate.collectionView(collectionView, heightForSupplementaryViewOfKind: DealCollectionViewLayout.infoHeaderElementKind, atIndexPath: indexPath, withWidth: contentWidth)
                }

                var frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: infoHeight)
                infoHeaderLayoutAttributes.frame = frame
                infoHeaderLayoutAttributes.zIndex = 0

                //configure button supplementary view
                var buttonHeight: CGFloat = 0.0
                if let delegate = delegate {
                    buttonHeight = delegate.collectionView(collectionView, heightForSupplementaryViewOfKind: DealCollectionViewLayout.buttonHeaderElementKind, atIndexPath: indexPath, withWidth: contentWidth)
                }

                yOffset += (collectionView.bounds.height - buttonHeight)

                frame = CGRect(x: xOffset, y: yOffset, width: contentWidth, height: buttonHeight)
                buttonHeaderLayoutAttributes.frame = frame
                buttonHeaderLayoutAttributes.zIndex = 2

                yOffset = buttonHeaderLayoutAttributes.frame.maxY

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
                allLayoutAttributes.append(infoHeaderLayoutAttributes)
                allLayoutAttributes.append(buttonHeaderLayoutAttributes)
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
        if elementKind == DealCollectionViewLayout.infoHeaderElementKind {
            if let collectionView = collectionView {
                infoHeaderLayoutAttributes.frame.origin.y = collectionView.contentOffset.y

                let modifier: CGFloat = 2.0
                let value = (min(collectionView.contentOffset.y, infoHeaderLayoutAttributes.frame.height) * modifier) / infoHeaderLayoutAttributes.frame.height
                let alpha = min(1, 1 - value)
                infoHeaderLayoutAttributes.alpha = alpha
            }

            return infoHeaderLayoutAttributes
        }
        else if elementKind == DealCollectionViewLayout.buttonHeaderElementKind {
            if let collectionView = collectionView {
                buttonHeaderLayoutAttributes.frame = buttonHeaderFrameForContentOffset(collectionView.contentOffset)
            }

            return buttonHeaderLayoutAttributes
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
                context.invalidateSupplementaryElementsOfKind(DealCollectionViewLayout.infoHeaderElementKind, atIndexPaths: [indexPath])
                context.invalidateSupplementaryElementsOfKind(DealCollectionViewLayout.buttonHeaderElementKind, atIndexPaths: [indexPath])
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

    // MARK: Frames

    private func buttonHeaderFrameForContentOffset(contentOffset: CGPoint) -> CGRect {
        var frame = buttonHeaderLayoutAttributes.frame

        if contentOffset.y > (collectionView!.bounds.height - frame.height) {
            frame.origin.y = contentOffset.y
            buttonHeaderLayoutAttributes.isPinned = true
        }
        else {
            frame.origin.y = collectionView!.bounds.height - frame.height
            buttonHeaderLayoutAttributes.isPinned = false
        }

        return frame
    }

    private func footerFrame() -> CGRect {
        var frame: CGRect = CGRect.zero

        if let collectionView = collectionView {
            let threshold = collectionView.contentOffset.y + collectionView.bounds.height
            let height = max(0.0, threshold - contentHeight)

            frame = CGRect(x: 0.0, y: contentHeight, width: contentWidth, height: height)
        }

        return frame
    }
}
