//
//  VideoViewController.swift
//  Meh
//
//  Created by Bradley Smith on 6/13/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoViewController: UIViewController {
    private let viewModel: VideoViewModel
    private let originalRect: CGRect
    private let containerView = UIView(frame: .zero)
    private let videoImageView = UIImageView(frame: .zero)
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    private let animationController = FocusAnimationController(positive: true)
    private let playerView = YTPlayerView(frame: .zero)
    private let playerVariables = [
        "rel": 0,
        "showinfo": 0,
        "controls": 0,
        "iv_load_policy": 3,
        "modestbranding": 1,
        "playsinline": 1
    ]

    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    private var didLayoutSubviews = false
    private var dismissing = false
    private var videoLoading = false {
        didSet {
            if videoLoading {
                spinner.startAnimating()
                blurView.hidden = false
            }
            else {
                spinner.stopAnimating()
                blurView.hidden = true
            }
        }
    }

    weak var delegate: FocusableViewControllerDelegate?

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }

    init(viewModel: VideoViewModel, originalRect: CGRect) {
        self.viewModel = viewModel
        self.originalRect = originalRect

        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = self
        modalPresentationStyle = .Custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.clearColor()

        configureViews()
        configureLayout()

        configureWithViewModel(viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(VideoViewController.handleTap))
        view.addGestureRecognizer(tapGesture)

        if let videoID = viewModel.videoURL?.absoluteString.youtubeVideoID() {
            videoLoading = true
            playerView.loadWithVideoId(videoID, playerVars: playerVariables)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let animation = { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.delegate?.viewControllerWillStartPresentAnimation(self)

            self.containerView.transform = CGAffineTransformIdentity
        }

        transitionCoordinator()?.animateAlongsideTransition(animation, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !didLayoutSubviews {
            didLayoutSubviews = true

            let y = originalRect.minY - containerView.frame.minY
            containerView.transform = CGAffineTransformMakeTranslation(0.0, y)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        let animation = { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            let y = self.originalRect.minY - self.containerView.frame.minY
            self.containerView.transform = CGAffineTransformMakeTranslation(0.0, y)
        }

        let completion = { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            if !context.isCancelled() {
                self.delegate?.viewControllerDidFinishDismissAnimation(self)
            }
        }

        transitionCoordinator()?.animateAlongsideTransition(animation, completion: completion)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        let animation = { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            if size.width > size.height {
                NSLayoutConstraint.deactivateConstraints(self.portraitConstraints)
                NSLayoutConstraint.activateConstraints(self.landscapeConstraints)
            }
            else {
                NSLayoutConstraint.deactivateConstraints(self.landscapeConstraints)
                NSLayoutConstraint.activateConstraints(self.portraitConstraints)
            }

            self.view.layoutIfNeeded()
        }

        coordinator.animateAlongsideTransition(animation, completion: nil)
    }
}

// MARK: - Private

private extension VideoViewController {
    func configureViews() {
        containerView.backgroundColor = UIColor.clearColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        videoImageView.clipsToBounds = true
        videoImageView.contentMode = .ScaleAspectFill
        videoImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(videoImageView)

        blurView.layer.cornerRadius = 40.0
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(blurView)

        spinner.color = UIColor.blackColor()
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(spinner)

        playerView.delegate = self
    }

    func configureLayout() {
        portraitConstraints = [
            containerView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
            videoImageView.heightAnchor.constraintEqualToConstant(MediaCell.height() - 20.0)
        ]

        landscapeConstraints = [
            containerView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            view.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor)
        ]

        let constraints: [NSLayoutConstraint] = [
            containerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor),

            videoImageView.topAnchor.constraintEqualToAnchor(containerView.topAnchor),
            videoImageView.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor),
            containerView.trailingAnchor.constraintEqualToAnchor(videoImageView.trailingAnchor),
            containerView.bottomAnchor.constraintEqualToAnchor(videoImageView.bottomAnchor),

            blurView.widthAnchor.constraintEqualToConstant(80.0),
            blurView.heightAnchor.constraintEqualToConstant(80.0),
            blurView.centerXAnchor.constraintEqualToAnchor(videoImageView.centerXAnchor),
            blurView.centerYAnchor.constraintEqualToAnchor(videoImageView.centerYAnchor),

            spinner.centerXAnchor.constraintEqualToAnchor(blurView.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(blurView.centerYAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
        NSLayoutConstraint.activateConstraints(portraitConstraints)
    }

    func configureWithViewModel(viewModel: VideoViewModel) {
        if let thumbnailURL = viewModel.videoThumbnailURL {
            videoImageView.af_setImageWithURL(thumbnailURL, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.5), runImageTransitionIfCached: false, completion: nil)
        }
        else {
            videoImageView.image = nil
        }

        videoLoading = true
    }

    @objc func handleTap() {
        dismissing = true

        playerView.removeFromSuperview()
        playerView.clearVideo()
        playerView.stopVideo()

        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - YTPlayerViewDelegate

extension VideoViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        if !dismissing {
            playerView.frame = containerView.bounds
            containerView.addSubview(playerView)

            playerView.playVideo()
        }
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
        videoLoading = false
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension VideoViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.positive = false

        return animationController
    }
}
