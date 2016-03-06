//
//  InfoHeaderView.swift
//  Meh
//
//  Created by Bradley Smith on 3/3/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol InfoHeaderViewDelegate {
    func didSelectPhotoWithURL(URL: NSURL, rect: CGRect, alpha: CGFloat)
}

class InfoHeaderView: UICollectionReusableView {

    // MARK: - Properties

    private static let spacing: CGFloat = 40.0
    private static let photoCellWidth: CGFloat = UIScreen.mainScreen().bounds.width - (2.0 * spacing)

    private let photoCollectionView: UICollectionView
    private let pageControl = PageControl(frame: CGRect.zero)

    private var deal: Deal?
    private var selectedCell: UICollectionViewCell?

    var delegate: InfoHeaderViewDelegate?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 2.0 * InfoHeaderView.spacing
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: InfoHeaderView.spacing, bottom: 0.0, right: InfoHeaderView.spacing)
        layout.itemSize = CGSize(width: InfoHeaderView.photoCellWidth, height: InfoHeaderView.photoCellWidth)
        photoCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        super.init(frame: frame)

        configureViews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
//        super.applyLayoutAttributes(layoutAttributes)
//
//        let transform = CGAffineTransformMakeScale(layoutAttributes.alpha, layoutAttributes.alpha)
//        photoCollectionView.transform = transform
//        pageControl.transform = transform
//        nameLabel.transform = transform
//    }

    // MARK: - Setup

    private func configureViews() {
        photoCollectionView.showsHorizontalScrollIndicator = false
        photoCollectionView.pagingEnabled = true
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.backgroundColor = UIColor.clearColor()
        photoCollectionView.registerClass(PhotoCell.self, forCellWithReuseIdentifier: "Cell")
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(photoCollectionView)

        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = 0
        pageControl.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        pageControl.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Vertical)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
    }

    private func configureLayout() {
        let photoCollectionViewConstraints: [NSLayoutConstraint] = [
            photoCollectionView.heightAnchor.constraintEqualToConstant(InfoHeaderView.photoCellWidth),
            photoCollectionView.topAnchor.constraintEqualToAnchor(topAnchor, constant: 10.0),
            photoCollectionView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailingAnchor.constraintEqualToAnchor(photoCollectionView.trailingAnchor)
        ]

        NSLayoutConstraint.activateConstraints(photoCollectionViewConstraints)

        let pageControlConstraints: [NSLayoutConstraint] = [
            pageControl.topAnchor.constraintEqualToAnchor(photoCollectionView.bottomAnchor, constant: 10.0),
            pageControl.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            bottomAnchor.constraintEqualToAnchor(pageControl.bottomAnchor, constant: 10.0)
        ]

        NSLayoutConstraint.activateConstraints(pageControlConstraints)
    }

    func configureWithDeal(deal: Deal?) {
        self.deal = deal

        pageControl.numberOfPages = deal?.photoURLs.count ?? 0
        pageControl.pageIndicatorTintColor = deal?.theme.accentColor
        pageControl.currentPageIndicatorTintColor = deal?.theme.accentColor
    }

    // MARK: - Actions

    func hideSelectedCell() {
        selectedCell?.hidden = true
    }

    func showSelectedCell() {
        selectedCell?.hidden = false
    }

    static func height() -> CGFloat {
        return InfoHeaderView.photoCellWidth + PageControl.height() + (3 * 10.0)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension InfoHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deal?.photoURLs.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as? PhotoCell {
            var URL: NSURL?

            if let photoURLs = deal?.photoURLs {
                if indexPath.item < photoURLs.count {
                    URL = photoURLs[indexPath.item]
                }
            }

            cell.configureWithURL(URL)

            return cell
        }
        else {
            preconditionFailure("Cell must be of type PhotoCell")
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let photoURLs = deal?.photoURLs {
            if indexPath.item < photoURLs.count {
                let URL = photoURLs[indexPath.item]
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                    if let rect = window?.convertRect(cell.frame, fromView: cell.superview) {
                        selectedCell = cell
                        delegate?.didSelectPhotoWithURL(URL, rect: rect, alpha: alpha)
                    }
                }
            }
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == photoCollectionView {
            let index = scrollView.contentOffset.x / scrollView.frame.width
            pageControl.currentPage = Int(floor(index))
        }
    }
}
