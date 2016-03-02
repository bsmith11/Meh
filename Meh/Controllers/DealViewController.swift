//
//  DealViewController.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class DealViewController: UIViewController {

    // MARK: - Properties

    private var viewModel: DealViewModel
    private var photoCollectionView: UICollectionView
    private var pageControl = UIPageControl(frame: CGRect.zero)
    private var nameLabel = UILabel(frame: CGRect.zero)
    private var dealTableView = UITableView(frame: CGRect.zero, style: .Plain)

    // MARK: - Lifecycle

    init(viewModel: DealViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsetsZero
        layout.itemSize = CGSize(width: 375.0, height: 100.0)
        photoCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()

        configureViews()
        configureLayout()
        configureTheme()
    }

    // MARK: - Setup

    private func configureViews() {
        photoCollectionView.showsHorizontalScrollIndicator = false
        photoCollectionView.pagingEnabled = true
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoCollectionView)

        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = 3
        view.addSubview(pageControl)

        nameLabel.attributedText = viewModel.dealName
        view.addSubview(nameLabel)

        dealTableView.dataSource = self
        dealTableView.delegate = self
        dealTableView.showsVerticalScrollIndicator = false
        view.addSubview(dealTableView)
    }

    private func configureLayout() {
        let photoCollectionViewConstraints: [NSLayoutConstraint] = [
            photoCollectionView.heightAnchor.constraintEqualToConstant(100.0),
            photoCollectionView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            photoCollectionView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(photoCollectionView.trailingAnchor)
        ]

        NSLayoutConstraint.activateConstraints(photoCollectionViewConstraints)

        let pageControlConstraints: [NSLayoutConstraint] = [
            pageControl.topAnchor.constraintEqualToAnchor(photoCollectionView.bottomAnchor),
            pageControl.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
        ]

        NSLayoutConstraint.activateConstraints(pageControlConstraints)

        let nameLabelConstraints: [NSLayoutConstraint] = [
            nameLabel.topAnchor.constraintEqualToAnchor(pageControl.bottomAnchor),
            nameLabel.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(nameLabel.trailingAnchor)
        ]

        NSLayoutConstraint.activateConstraints(nameLabelConstraints)

        let dealTableViewConstraints: [NSLayoutConstraint] = [
            dealTableView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            dealTableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(dealTableView.trailingAnchor),
            view.bottomAnchor.constraintEqualToAnchor(dealTableView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(dealTableViewConstraints)
    }

    private func configureTheme() {
        view.backgroundColor = viewModel.dealTheme?.backgroundColor
        pageControl.pageIndicatorTintColor = viewModel.dealTheme?.foregroundColor
        pageControl.currentPageIndicatorTintColor = viewModel.dealTheme?.accentColor
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension DealViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as? PhotoCell {

            cell.configureWithURL(nil)

            return cell
        }
        else {
            preconditionFailure("Cell must be of type PhotoCell")
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension DealViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell(frame: CGRect.zero)
    }
}