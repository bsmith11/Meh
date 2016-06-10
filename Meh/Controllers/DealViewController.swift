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

typealias AnimationCompletion = (Bool) -> Void

class DealViewController: UIViewController {
    private let viewModel: DealViewModel
    private let collectionView: ControlContainableCollectionView
    private let playerView = YTPlayerView(frame: .zero)
    private let playerVariables = [
        "rel": 0,
        "showinfo": 0
    ]

    private var selectedPhotoHeaderView: PhotosHeaderView?
    private var didAppear = false
    private var animationsComplete = false
    private var videoLoading = false {
        didSet {
            if let indexPath = viewModel.indexPathForItem(.Video) where videoLoading != oldValue {
                if animationsComplete {
                    self.collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            }
        }
    }

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

        self.collectionView.alpha = 0.0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !didAppear {
            didAppear = true

            dispatch_async(dispatch_get_main_queue(), {
                self.displayContentAnimated(true)
            })
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
        collectionView.registerClass(SpecsCell.self)
        collectionView.registerClass(VideoCell.self)
        collectionView.registerClass(StoryCell.self)
        collectionView.registerClass(PhotosHeaderView.self, elementKind: DealCollectionViewLayout.photosHeaderElementKind)
        collectionView.registerClass(TitleHeaderView.self, elementKind: DealCollectionViewLayout.titleHeaderElementKind)
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
        let animations = {
            self.view.backgroundColor = self.viewModel.deal?.theme.backgroundColor ?? UIColor.whiteColor()
        }

        let completion = { (finished: Bool) in
            var contentOffset = self.collectionView.contentOffset
            let titleHeaderViewModel = TitleHeaderViewModel(deal: self.viewModel.deal)

            contentOffset.y = -TitleHeaderView.heightWithViewModel(titleHeaderViewModel, width: self.collectionView.bounds.width)
            self.collectionView.setContentOffset(contentOffset, animated: false)

            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            let photosHeaderView = self.collectionView.supplementaryViewForElementKind(DealCollectionViewLayout.photosHeaderElementKind, atIndexPath: indexPath) as? PhotosHeaderView

            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.alpha = 1.0
                self.bounceContentOffsetWithCompletion({ [weak self] (finished: Bool) in
                    self?.animationsComplete = true
                })

                photosHeaderView?.showPageControlAnimated(true)
            })
        }

        UIView.animateWithDuration(0.75, animations: animations, completion: completion)
    }

    func bounceContentOffsetWithCompletion(completion: AnimationCompletion?) {
        let bounceAnimation = POPSpringAnimation(propertyNamed: kPOPCollectionViewContentOffset)
        bounceAnimation.toValue = NSValue(CGPoint: .zero)
        bounceAnimation.springBounciness = 20.0
        bounceAnimation.springSpeed = 4.0
        bounceAnimation.completionBlock = { (animation: POPAnimation?, finished: Bool) in
            completion?(finished)
        }

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
        case .Specs:
            let specsViewModel = SpecsViewModel(deal: viewModel.deal)
            let cell: SpecsCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(specsViewModel)

            return cell
        case .Video:
            let videoViewModel = VideoViewModel(deal: viewModel.deal, loading: videoLoading)
            let cell: VideoCell = collectionView.dequeueCellForIndexPath(indexPath)
            cell.configureWithViewModel(videoViewModel, delegate: self)

            return cell
        case .Story:
            let storyViewModel = StoryViewModel(deal: viewModel.deal)
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
        case DealCollectionViewLayout.titleHeaderElementKind:
            let header: TitleHeaderView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            let titleHeaderViewModel = TitleHeaderViewModel(deal: viewModel.deal)
            header.configureWithViewModel(titleHeaderViewModel)

            return header
        case DealCollectionViewLayout.buyHeaderElementKind:
            let header: BuyHeaderView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            let buyHeaderViewModel = BuyHeaderViewModel(deal: viewModel.deal)
            header.configureWithViewModel(buyHeaderViewModel)
            header.delegate = self

            return header
        case DealCollectionViewLayout.footerElementKind:
            let footer: FooterView = collectionView.dequeueSupplementaryViewForElementKind(kind, indexPath: indexPath)
            footer.configureWithTheme(viewModel.deal?.theme ?? Theme())

            return footer
        default:
            preconditionFailure("Invalid element kind")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension DealViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let item = viewModel.itemAtIndexPath(indexPath) {
            if case .Specs = item {
                let specsViewModel = SpecsViewModel(deal: viewModel.deal)
                let specsViewController = SpecsViewController(viewModel: specsViewModel)

                presentViewController(specsViewController, animated: true, completion: nil)
            }
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        collectionView.pop_removeAnimationForKey("bounce")
    }
}

// MARK: - DealCollectionViewLayoutDelegate

extension DealViewController: DealCollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath, width: CGFloat) -> CGFloat {
        guard let item = viewModel.itemAtIndexPath(indexPath) else {
            preconditionFailure("Item is nil")
        }

        switch item {
        case .Features:
            let featuresViewModel = FeaturesViewModel(deal: viewModel.deal)

            return FeaturesCell.heightWithViewModel(featuresViewModel, width: width)
        case .Specs:
            let specsViewModel = SpecsViewModel(deal: viewModel.deal)

            return SpecsCell.heightWithViewModel(specsViewModel, width: width)
        case .Video:
            return VideoCell.height()
        case .Story:
            let storyViewModel = StoryViewModel(deal: viewModel.deal)

            return StoryCell.heightWithViewModel(storyViewModel, width: width)
        }
    }

    func collectionView(collectionView: UICollectionView, sizeForSupplementaryViewOfKind kind: String, width: CGFloat) -> CGSize {
        switch kind {
        case DealCollectionViewLayout.photosHeaderElementKind:
            let photosHeaderViewModel = PhotosHeaderViewModel(deal: viewModel.deal)
            let height = PhotosHeaderView.heightWithViewModel(photosHeaderViewModel, width: width)

            return CGSize(width: width, height: height)
        case DealCollectionViewLayout.titleHeaderElementKind:
            let titleHeaderViewModel = TitleHeaderViewModel(deal: viewModel.deal)
            let height = TitleHeaderView.heightWithViewModel(titleHeaderViewModel, width: width)

            return CGSize(width: width, height: height)
        case DealCollectionViewLayout.buyHeaderElementKind:
            let buyHeaderViewModel = BuyHeaderViewModel(deal: viewModel.deal)

            return BuyHeaderView.sizeWithViewModel(buyHeaderViewModel)
        default:
            return .zero
        }
    }
}

// MARK: - PhotosHeaderViewDelegate

extension DealViewController: PhotosHeaderViewDelegate {
    func photosHeaderView(headerView: PhotosHeaderView, didSelectPhotoWithURL URL: NSURL, rect: CGRect) {
        selectedPhotoHeaderView = headerView

        let originalRect = view.convertRect(rect, fromView: view.window)
        let imageViewController = ImageViewController(URL: URL, originalRect: originalRect)
        imageViewController.delegate = self

        presentViewController(imageViewController, animated: true, completion: nil)
    }
}

// MARK: - BuyHeaderViewDelegate

extension DealViewController: BuyHeaderViewDelegate {
    func buyHeaderViewDidSelectBuy(headerView: BuyHeaderView) {
        if viewModel.deal?.soldOutDate == nil {
            if let URL = viewModel.deal?.URL {
                let rect = view.convertRect(headerView.frame, fromView: headerView.superview)
                let webViewController = WebViewController(rect: rect, URL: URL)

                presentViewController(webViewController, animated: true, completion: nil)
            }
        }
        else {
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            if let titleHeaderView = collectionView.supplementaryViewForElementKind(DealCollectionViewLayout.titleHeaderElementKind, atIndexPath: indexPath) as? TitleHeaderView {
                titleHeaderView.bounceTitle()
            }
        }
    }
}

// MARK: - VideoCellDelegate

extension DealViewController: VideoCellDelegate {
    func videoCellDidSelectVideo(cell: VideoCell) {
        if let videoID = viewModel.deal?.videoURL?.absoluteString.youtubeVideoID() {
            videoLoading = true

            if playerView.playerState() == .Unknown {
                playerView.loadWithVideoId(videoID, playerVars: playerVariables)
            }
            else {
                playerView.playVideo()
            }
        }
    }
}

// MARK: - YTPlayerViewDelegate

extension DealViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        playerView.playVideo()
    }

    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        switch state {
        case .Buffering:
            videoLoading = true
        default:
            videoLoading = false
        }
    }

    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print("Failed with error: \(error)")

        videoLoading = false
    }
}

// MARK: - ImageViewControllerDelegate

extension DealViewController: ImageViewControllerDelegate {
    func imageViewControllerWillStartPresentAnimation(imageViewController: ImageViewController) {
        selectedPhotoHeaderView?.hideSelectedCell()
    }

    func imageViewControllerDidFinishDismissAnimation(imageViewController: ImageViewController) {
        selectedPhotoHeaderView?.showSelectedCell()
        selectedPhotoHeaderView = nil
    }
}
