//
//  PhotosHeaderView.swift
//  Meh
//
//  Created by Bradley Smith on 5/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol PhotosHeaderViewDelegate: NSObjectProtocol {
    func photosHeaderView(headerView: PhotosHeaderView, didSelectPhotoWithURL URL: NSURL, rect: CGRect, alpha: CGFloat)
}

class PhotosHeaderView: UICollectionReusableView {
    private static let spacing = CGFloat(40.0)
    private static let photoCellWidth = UIScreen.mainScreen().bounds.width - (2.0 * spacing)

    private let collectionView: UICollectionView
    private let pageControl = PageControl(frame: .zero)

    private var viewModel: PhotosHeaderViewModel?
    private var selectedCell: UICollectionViewCell?
    private var runImageTransitionIfCached = true

    weak var delegate: PhotosHeaderViewDelegate?

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 2.0 * PhotosHeaderView.spacing
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: PhotosHeaderView.spacing, bottom: 0.0, right: PhotosHeaderView.spacing)
        layout.itemSize = CGSize(width: PhotosHeaderView.photoCellWidth, height: PhotosHeaderView.photoCellWidth)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: frame)

        configureViews()
        configureLayout()

        collectionView.alpha = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension PhotosHeaderView {
    func configureWithViewModel(viewModel: PhotosHeaderViewModel) {
        self.viewModel = viewModel

        pageControl.numberOfPages = viewModel.numberOfItems()
        pageControl.pageIndicatorTintColor = viewModel.theme.accentColor
        pageControl.currentPageIndicatorTintColor = viewModel.theme.accentColor

        hidePageControl()

        let animations = {
            self.collectionView.alpha = 1.0
        }

        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(0.5, delay: 1.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: animations, completion: nil)
        }
    }

    func hideSelectedCell() {
        selectedCell?.hidden = true
    }

    func showSelectedCell() {
        selectedCell?.hidden = false
    }

    func showPageControlAnimated(animated: Bool) {
        pageControl.showAnimated(animated)
    }

    func hidePageControl() {
        pageControl.hide()
    }
}

// MARK: - Private

private extension PhotosHeaderView {
    func configureViews() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.pagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.registerClass(PhotoCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)

        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = 0
        pageControl.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        pageControl.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Vertical)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            collectionView.heightAnchor.constraintEqualToConstant(PhotosHeaderView.photoCellWidth),
            collectionView.topAnchor.constraintEqualToAnchor(topAnchor, constant: 20.0),
            collectionView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailingAnchor.constraintEqualToAnchor(collectionView.trailingAnchor),

            pageControl.topAnchor.constraintEqualToAnchor(collectionView.bottomAnchor, constant: 20.0),
            pageControl.centerXAnchor.constraintEqualToAnchor(centerXAnchor),
            bottomAnchor.constraintEqualToAnchor(pageControl.bottomAnchor, constant: 20.0)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}

// MARK: - Static

extension PhotosHeaderView {
    static func height() -> CGFloat {
        return PhotosHeaderView.photoCellWidth + PageControl.height() + (3 * 20.0)
    }
}

// MARK: - UICollectionViewDataSource

extension PhotosHeaderView: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.viewModel?.numberOfSections() ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.numberOfItems() ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let URL = viewModel?.itemAtIndexPath(indexPath)
        let cell: PhotoCell = collectionView.dequeueCellForIndexPath(indexPath)
        cell.configureWithURL(URL, runImageTransitionIfCached: runImageTransitionIfCached)

        if runImageTransitionIfCached {
            runImageTransitionIfCached = false
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension PhotosHeaderView: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCell {
            if let rect = window?.convertRect(cell.frame, fromView: cell.superview),
                URL = viewModel?.itemAtIndexPath(indexPath) {
                selectedCell = cell
                delegate?.photosHeaderView(self, didSelectPhotoWithURL: URL, rect: rect, alpha: alpha)
            }
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == collectionView {
            let index = scrollView.contentOffset.x / scrollView.frame.width
            pageControl.currentPage = Int(floor(index))
        }
    }
}