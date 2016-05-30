//
//  DealViewController.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import SafariServices
import pop

class DealViewController: UIViewController {
    private let viewModel: DealViewModel
    private let collectionView: ControlContainableCollectionView
    private let playerView = YTPlayerView(frame: .zero)
    private let playerVariables = [
        "rel": 0,
        "showinfo": 0
    ]

    private var didAppear = false

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    init(viewModel: DealViewModel) {
        self.viewModel = viewModel

        let layout = DealCollectionViewLayout()
        collectionView = ControlContainableCollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)

        layout.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.whiteColor()

        configureViews()
        configureLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let videoID = viewModel.deal?.videoURL?.absoluteString.youtubeVideoID() {
            playerView.loadWithVideoId(videoID, playerVars: playerVariables)
        }

        self.collectionView.alpha = 0.0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !didAppear {
            didAppear = true

            if let videoID = viewModel.deal?.videoURL?.absoluteString.youtubeVideoID() {
                playerView.loadWithVideoId(videoID, playerVars: playerVariables)
            }

            displayContentAnimated(true)
        }
    }
}

// MARK: - Private

private extension DealViewController {
    func configureViews() {
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delaysContentTouches = false
        collectionView.registerClass(FeaturesCell.self)
        collectionView.registerClass(VideoCell.self)
        collectionView.registerClass(StoryCell.self)
        collectionView.registerClass(PhotosHeaderView.self, elementKind: DealCollectionViewLayout.photosHeaderElementKind)
        collectionView.registerClass(BuyHeaderView.self, elementKind: DealCollectionViewLayout.buyHeaderElementKind)
        collectionView.registerClass(FooterView.self, elementKind: DealCollectionViewLayout.footerElementKind)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        playerView.delegate = self
        playerView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            collectionView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            collectionView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(collectionView.trailingAnchor),
            view.bottomAnchor.constraintEqualToAnchor(collectionView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

    func displayContentAnimated(animated: Bool) {
        let animations = { () -> Void in
            self.view.backgroundColor = self.viewModel.deal?.theme.backgroundColor ?? UIColor.whiteColor()
        }

        let completion = { (finished: Bool) -> Void in
            var contentOffset = self.collectionView.contentOffset
            let buyHeaderViewModel = BuyHeaderViewModel(deal: self.viewModel.deal)

            contentOffset.y = -BuyHeaderView.heightWithViewModel(buyHeaderViewModel, width: self.collectionView.bounds.width)
            self.collectionView.setContentOffset(contentOffset, animated: false)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView.alpha = 1.0
                self.bounceContentOffset()

                if let photosHeaderView = self.collectionView.supplementaryViewForElementKind(DealCollectionViewLayout.photosHeaderElementKind, atIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? PhotosHeaderView {
                    photosHeaderView.showPageControlAnimated(true)
                }
            })
        }

        UIView.animateWithDuration(0.75, animations: animations, completion: completion)
    }

    func bounceContentOffset() {
        let bounceAnimation = POPSpringAnimation(propertyNamed: kPOPCollectionViewContentOffset)
        bounceAnimation.toValue = NSValue(CGPoint: .zero)
        bounceAnimation.springBounciness = 5.0
        bounceAnimation.springSpeed = 1.0

        collectionView.pop_addAnimation(bounceAnimation, forKey: "bounce")
    }

    func handleURL(URL: NSURL) {
        let safariViewController = SFSafariViewController(URL: URL)
        presentViewController(safariViewController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension DealViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let item = viewModel.itemAtIndexPath(indexPath) else {
            preconditionFailure("Item is nil")
        }

        switch item {
        case .Features:
            let featuresViewModel = FeaturesViewModel(deal: viewModel.deal)
            let cell: FeaturesCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(featuresViewModel)
            cell.linkHandler = { [weak self] (URL: NSURL) in
                self?.handleURL(URL)
            }

            return cell
        case .Video:
            let videoViewModel = VideoViewModel(deal: viewModel.deal)
            let cell: VideoCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(videoViewModel, delegate: self)

            return cell
        case .Story:
            let storyViewModel = StoryViewModel(story: viewModel.deal?.story)
            let cell: StoryCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(storyViewModel)
            cell.linkHandler = { [weak self] (URL: NSURL) in
                self?.handleURL(URL)
            }

            return cell
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case DealCollectionViewLayout.photosHeaderElementKind:
            let header: PhotosHeaderView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            let photosHeaderViewModel = PhotosHeaderViewModel(deal: viewModel.deal)
            header.configureWithViewModel(photosHeaderViewModel)
            header.delegate = self

            return header
        case DealCollectionViewLayout.buyHeaderElementKind:
            let header: BuyHeaderView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            let buyHeaderViewModel = BuyHeaderViewModel(deal: viewModel.deal)
            header.configureWithViewModel(buyHeaderViewModel)
            header.delegate = self

            return header
        case DealCollectionViewLayout.footerElementKind:
            let footer: FooterView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)

            return footer
        default:
            preconditionFailure("Invalid element kind")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension DealViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        collectionView.pop_removeAnimationForKey("bounce")
    }
}

// MARK: - DealCollectionViewLayoutDelegate

extension DealViewController: DealCollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        guard let item = viewModel.itemAtIndexPath(indexPath) else {
            preconditionFailure("Item is nil")
        }

        switch item {
        case .Features:
            let featuresViewModel = FeaturesViewModel(deal: viewModel.deal)

            return FeaturesCell.heightWithViewModel(featuresViewModel, width: width)
        case .Video:
            return VideoCell.height()
        case .Story:
            let storyViewModel = StoryViewModel(story: viewModel.deal?.story)

            return StoryCell.heightWithViewModel(storyViewModel, width: width)
        }
    }

    func collectionView(collectionView: UICollectionView, heightForSupplementaryViewOfKind kind: String, atIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        switch kind {
        case DealCollectionViewLayout.photosHeaderElementKind:
            return PhotosHeaderView.height()
        case DealCollectionViewLayout.buyHeaderElementKind:
            let buyHeaderViewModel = BuyHeaderViewModel(deal: viewModel.deal)

            return BuyHeaderView.heightWithViewModel(buyHeaderViewModel, width: width)
        default:
            return 0.0
        }
    }
}

// MARK: - PhotosHeaderViewDelegate

extension DealViewController: PhotosHeaderViewDelegate {
    func photosHeaderView(headerView: PhotosHeaderView, didSelectPhotoWithURL URL: NSURL, rect: CGRect, alpha: CGFloat) {
        let originalRect = view.convertRect(rect, fromView: view.window)
        let imageViewController = ImageViewController(URL: URL, originalRect: originalRect, originalAlpha: alpha)
        imageViewController.delegate = self

        presentViewController(imageViewController, animated: true, completion: nil)
    }
}

// MARK: - BuyHeaderViewDelegate

extension DealViewController: BuyHeaderViewDelegate {
    func buyHeaderViewDidSelectBuy(headerView: BuyHeaderView) {
        if viewModel.deal?.soldOutDate == nil {
            if let URL = viewModel.deal?.URL {
                handleURL(URL)
            }
        }
        else {
            //TODO: Handle sold out case
        }
    }
}

// MARK: - VideoCellDelegate

extension DealViewController: VideoCellDelegate {
    func videoCellDidSelectVideo(cell: VideoCell) {
        playerView.playVideo()
    }
}

// MARK: - YTPlayerViewDelegate

extension DealViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        print("Ready...")
    }

    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        print("State: \(state.rawValue)")
    }

    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print("Error: \(error)")
    }
}

// MARK: - ImageViewControllerDelegate

extension DealViewController: ImageViewControllerDelegate {
    func imageViewControllerWillStartPresentAnimation(imageViewController: ImageViewController) {
        if let photosHeaderView = collectionView.supplementaryViewForElementKind(DealCollectionViewLayout.photosHeaderElementKind, atIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? PhotosHeaderView {
            photosHeaderView.hideSelectedCell()
        }
    }

    func imageViewControllerDidFinishDismissAnimation(imageViewController: ImageViewController) {
        if let photosHeaderView = collectionView.supplementaryViewForElementKind(DealCollectionViewLayout.photosHeaderElementKind, atIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? PhotosHeaderView {
            photosHeaderView.showSelectedCell()
        }

        dismissViewControllerAnimated(false, completion: nil)
    }
}
