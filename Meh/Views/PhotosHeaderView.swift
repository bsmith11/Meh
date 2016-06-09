//
//  PhotosHeaderView.swift
//  Meh
//
//  Created by Bradley Smith on 5/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol PhotosHeaderViewDelegate: NSObjectProtocol {
    func photosHeaderView(headerView: PhotosHeaderView, didSelectPhotoWithURL URL: NSURL, rect: CGRect)
}

class PhotosHeaderView: UICollectionReusableView {
    private static let spacing = CGFloat(40.0)
    private static let photoCellWidth = UIScreen.mainScreen().bounds.width - (2.0 * spacing)

    private let collectionView: UICollectionView
    private let pageControl = PageControl(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)

    private var viewModel: PhotosHeaderViewModel?
    private var selectedCell: UICollectionViewCell?
    private var runImageTransitionIfCached = true
    private var isInitialDisplay = true

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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        if isInitialDisplay {
            isInitialDisplay = false
        }
    }
}

// MARK: - Public

extension PhotosHeaderView {
    func configureWithViewModel(viewModel: PhotosHeaderViewModel) {
        self.viewModel = viewModel

        pageControl.numberOfPages = viewModel.numberOfItems()
        pageControl.pageIndicatorTintColor = viewModel.theme.accentColor
        pageControl.currentPageIndicatorTintColor = viewModel.theme.accentColor

        if isInitialDisplay {
            hidePageControl()
        }

        titleLabel.attributedText = viewModel.titleAttributedString
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

        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            collectionView.heightAnchor.constraintEqualToConstant(PhotosHeaderView.photoCellWidth),
            collectionView.topAnchor.constraintEqualToAnchor(topAnchor, constant: 20.0),
            collectionView.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailingAnchor.constraintEqualToAnchor(collectionView.trailingAnchor),

            pageControl.topAnchor.constraintEqualToAnchor(collectionView.bottomAnchor, constant: 20.0),
            pageControl.centerXAnchor.constraintEqualToAnchor(centerXAnchor),

            titleLabel.topAnchor.constraintEqualToAnchor(pageControl.bottomAnchor, constant: 20.0),
            titleLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 40.0),
            trailingAnchor.constraintEqualToAnchor(titleLabel.trailingAnchor, constant: 40.0),
            bottomAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 20.0)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}

// MARK: - Static

extension PhotosHeaderView {
    static func heightWithViewModel(viewModel: PhotosHeaderViewModel, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 80.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let titleHeight = viewModel.titleAttributedString.heightForSize(size)

        return 20.0 + PhotosHeaderView.photoCellWidth + 20.0 + PageControl.height() + 20.0 + titleHeight + 20.0
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
                delegate?.photosHeaderView(self, didSelectPhotoWithURL: URL, rect: rect)
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
