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
import Shimmer

class DealViewController: UIViewController {

    // MARK: - Properties

    private let dealCollectionView: ControlContainableCollectionView
    private let playerView = YTPlayerView(frame: CGRect.zero)
    private let shimmerView = FBShimmeringView(frame: CGRect.zero)

    private var viewModel: DealViewModel
    private var didAppear = false

    private let playerVariables = [
        "rel": 0,
        "showinfo": 0
    ]

    // MARK: - Lifecycle

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    init(viewModel: DealViewModel) {
        self.viewModel = viewModel

        let layout = DealCollectionViewLayout()
        dealCollectionView = ControlContainableCollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var bottomInset = dealCollectionView.bounds.height - dealCollectionView.contentSize.height + dealCollectionView.bounds.height - ButtonHeaderView.heightWithDeal(viewModel.deal, width: dealCollectionView.bounds.width)
        bottomInset = max(0, bottomInset)

        dealCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0)

        if let imageView = shimmerView.contentView as? UIImageView {
            if let image = imageView.image {
                let x: CGFloat = view.frame.midX - (image.size.width / 2.0)
                let y: CGFloat = 120.0
                let frame = CGRect(x: x, y: y, width: image.size.width, height: image.size.height)

                shimmerView.frame = frame
                imageView.bounds = shimmerView.bounds
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let videoID = viewModel.deal?.videoURL?.absoluteString.youtubeVideoID() {
            playerView.loadWithVideoId(videoID, playerVars: playerVariables)
        }

        shimmerView.shimmering = true
    }

    // MARK: - Setup

    private func configureViews() {
        let image = UIImage(named: "meh_logo")!
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .Center
        imageView.image = image

        shimmerView.contentView = imageView
        view.addSubview(shimmerView)

        dealCollectionView.backgroundColor = UIColor.clearColor()
        dealCollectionView.dataSource = self
        dealCollectionView.delegate = self
        dealCollectionView.showsVerticalScrollIndicator = false
        dealCollectionView.alwaysBounceVertical = true
        dealCollectionView.delaysContentTouches = false
        dealCollectionView.registerClass(FeaturesCell.self, forCellWithReuseIdentifier: "Features")
        dealCollectionView.registerClass(VideoCell.self, forCellWithReuseIdentifier: "Video")
        dealCollectionView.registerClass(StoryCell.self, forCellWithReuseIdentifier: "Story")
        dealCollectionView.registerClass(InfoHeaderView.self, forSupplementaryViewOfKind: DealCollectionViewLayout.infoHeaderElementKind, withReuseIdentifier: "InfoHeader")
        dealCollectionView.registerClass(ButtonHeaderView.self, forSupplementaryViewOfKind: DealCollectionViewLayout.buttonHeaderElementKind, withReuseIdentifier: "ButtonHeader")
        dealCollectionView.registerClass(FooterView.self, forSupplementaryViewOfKind: DealCollectionViewLayout.footerElementKind, withReuseIdentifier: "Footer")
        dealCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dealCollectionView)

        playerView.delegate = self
        playerView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureLayout() {
        let dealCollectionViewConstraints: [NSLayoutConstraint] = [
            dealCollectionView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            dealCollectionView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(dealCollectionView.trailingAnchor),
            view.bottomAnchor.constraintEqualToAnchor(dealCollectionView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(dealCollectionViewConstraints)
    }

    // MARK: - Actions

    private func bounceContentOffset() {
        let bounceAnimation = POPSpringAnimation(propertyNamed: kPOPCollectionViewContentOffset)
        bounceAnimation.toValue = NSValue(CGPoint: CGPoint.zero)
        bounceAnimation.springBounciness = 5.0
        bounceAnimation.springSpeed = 1.0

        dealCollectionView.pop_addAnimation(bounceAnimation, forKey: "bounce")
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension DealViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return viewModel.deal != nil ? 1 : 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Features", forIndexPath: indexPath) as? FeaturesCell {
                cell.configureWithFeatures(viewModel.deal?.features)

                return cell
            }
            else {
                preconditionFailure("Nope")
            }
        }
        else if indexPath.item == 1 {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Video", forIndexPath: indexPath) as? VideoCell {
                cell.configureWithDeal(viewModel.deal)
                cell.delegate = self

                return cell
            }
            else {
                preconditionFailure("Nope")
            }
        }
        else {
            if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Story", forIndexPath: indexPath) as? StoryCell {
                cell.configureWithDeal(viewModel.deal)

                return cell
            }
            else {
                preconditionFailure("Nope")
            }
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == DealCollectionViewLayout.infoHeaderElementKind {
            if let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "InfoHeader", forIndexPath: indexPath) as? InfoHeaderView {
                header.configureWithDeal(viewModel.deal)
                header.delegate = self

                return header
            }
            else {
                preconditionFailure("Nope")
            }
        }
        else if kind == DealCollectionViewLayout.buttonHeaderElementKind {
            if let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ButtonHeader", forIndexPath: indexPath) as? ButtonHeaderView {
                header.configureWithDeal(viewModel.deal)
                header.delegate = self

                return header
            }
            else {
                preconditionFailure("Nope")
            }
        }
        else if kind == DealCollectionViewLayout.footerElementKind {
            if let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath) as? FooterView {

                return footer
            }
            else {
                preconditionFailure("Nope")
            }
        }
        else {
            preconditionFailure("Nope")
        }
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        dealCollectionView.pop_removeAnimationForKey("bounce")
    }
}

// MARK: - DealCollectionViewLayoutDelegate

extension DealViewController: DealCollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForItemAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        if indexPath.item == 0 {
            return FeaturesCell.heightWithFeatures(viewModel.deal?.features, width: width)
        }
        else if indexPath.item == 1 {
            return VideoCell.height()
        }
        else {
            return StoryCell.heightWithDeal(viewModel.deal, width: width)
        }
    }

    func collectionView(collectionView: UICollectionView, heightForSupplementaryViewOfKind kind: String, atIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        if kind == DealCollectionViewLayout.infoHeaderElementKind {
            return InfoHeaderView.height()
        }
        else if kind == DealCollectionViewLayout.buttonHeaderElementKind {
            return ButtonHeaderView.heightWithDeal(viewModel.deal, width: width)
        }
        else {
            return 0.0
        }
    }
}

// MARK: - DealViewModelDelegate

extension DealViewController: DealViewModelDelegate {
    func didUpdateDeal() {
        shimmerView.shimmering = false

        if let videoID = viewModel.deal?.videoURL?.absoluteString.youtubeVideoID() {
            playerView.loadWithVideoId(videoID, playerVars: playerVariables)
        }

        let animations = { () -> Void in
            self.view.backgroundColor = self.viewModel.deal?.theme.backgroundColor ?? UIColor.whiteColor()
            self.shimmerView.alpha = 0.0

            UIView.performWithoutAnimation({ () -> Void in
                self.dealCollectionView.alpha = 0.0
                self.dealCollectionView.reloadData()
            })
        }

        let completion = { (finished: Bool) -> Void in
            var contentOffset = self.dealCollectionView.contentOffset
            contentOffset.y = -ButtonHeaderView.heightWithDeal(self.viewModel.deal, width: self.dealCollectionView.bounds.width)
            self.dealCollectionView.setContentOffset(contentOffset, animated: false)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dealCollectionView.alpha = 1.0
                self.bounceContentOffset()

                if let infoHeaderView = self.dealCollectionView.supplementaryViewForElementKind(DealCollectionViewLayout.infoHeaderElementKind, atIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? InfoHeaderView {
                    infoHeaderView.showPageControlAnimated(true)
                }
            })
        }

        UIView.animateWithDuration(0.75, animations: animations, completion: completion)
    }
}

// MARK: - InfoHeaderViewDelegate

extension DealViewController: InfoHeaderViewDelegate {
    func didSelectPhotoWithURL(URL: NSURL, rect: CGRect, alpha: CGFloat) {
        let originalRect = view.convertRect(rect, fromView: view.window)
        let imageViewController = ImageViewController(URL: URL, originalRect: originalRect, originalAlpha: alpha)
        imageViewController.delegate = self
        imageViewController.modalPresentationStyle = .OverCurrentContext

        presentViewController(imageViewController, animated: false, completion: nil)
    }
}

// MARK: - ButtonHeaderViewDelegate

extension DealViewController: ButtonHeaderViewDelegate {
    func didSelectButton() {
        if viewModel.deal?.soldOutDate == nil {
            if let URL = viewModel.deal?.URL {
                let safariViewController = SFSafariViewController(URL: URL)
                presentViewController(safariViewController, animated: true, completion: nil)
            }
        }
        else {
            //Do something because it's sold out
        }
    }
}

// MARK: - VideoCellDelegate

extension DealViewController: VideoCellDelegate {
    func didSelectVideo() {
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
        if let infoHeaderView = dealCollectionView.supplementaryViewForElementKind(DealCollectionViewLayout.infoHeaderElementKind, atIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? InfoHeaderView {
            infoHeaderView.hideSelectedCell()
        }
    }

    func imageViewControllerDidFinishDismissAnimation(imageViewController: ImageViewController) {
        if let infoHeaderView = dealCollectionView.supplementaryViewForElementKind(DealCollectionViewLayout.infoHeaderElementKind, atIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? InfoHeaderView {
            infoHeaderView.showSelectedCell()
        }

        dismissViewControllerAnimated(false, completion: nil)
    }
}
