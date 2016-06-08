//
//  ImageViewController.swift
//  Meh
//
//  Created by Bradley Smith on 3/5/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import AlamofireImage
import pop

protocol ImageViewControllerDelegate: NSObjectProtocol {
    func imageViewControllerWillStartPresentAnimation(imageViewController: ImageViewController)
    func imageViewControllerDidFinishDismissAnimation(imageViewController: ImageViewController)
}

class ImageViewController: UIViewController {
    private let minimumZoom: CGFloat = 1.0
    private let maximumZoom: CGFloat = 2.0

    private let URL: NSURL
    private let originalRect: CGRect
    private let originalAlpha: CGFloat
    private let scrollView = UIScrollView(frame: .zero)
    private let imageView = UIImageView(frame: .zero)
    private let panGesture = UIPanGestureRecognizer(target: nil, action: nil)

    private var previousLocation: CGPoint = .zero
    private var interactionController: UIPercentDrivenInteractiveTransition?

    weak var delegate: ImageViewControllerDelegate?

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    init(URL: NSURL, originalRect: CGRect, originalAlpha: CGFloat) {
        self.URL = URL
        self.originalRect = originalRect
        self.originalAlpha = originalAlpha

        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = self
        modalPresentationStyle = .OverCurrentContext
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.clearColor()

        configureViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        panGesture.addTarget(self, action: #selector(ImageViewController.handlePan(_:)))
        scrollView.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImageViewController.handleTap))
        view.addGestureRecognizer(tapGesture)

        scrollView.alpha = originalAlpha
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        configureLayout()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let animations = { (context: UIViewControllerTransitionCoordinatorContext) in
            self.delegate?.imageViewControllerWillStartPresentAnimation(self)

            self.scrollView.center = self.view.center
            self.scrollView.alpha = 1.0
        }

        let completion = { (context: UIViewControllerTransitionCoordinatorContext) in

        }

        transitionCoordinator()?.animateAlongsideTransition(animations, completion: completion)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        let animations = { (context: UIViewControllerTransitionCoordinatorContext) in
            if self.interactionController == nil {
                self.scrollView.center = CGPoint(x: self.originalRect.midX, y: self.originalRect.midY)
                self.scrollView.alpha = self.originalAlpha
            }
        }

        let completion = { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.delegate?.imageViewControllerDidFinishDismissAnimation(self)
        }

        transitionCoordinator()?.animateAlongsideTransition(animations, completion: completion)
    }
}

// MARK: - Private

private extension ImageViewController {
    func configureViews() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.bouncesZoom = true
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.delegate = self
        scrollView.minimumZoomScale = minimumZoom
        scrollView.maximumZoomScale = maximumZoom
        scrollView.zoomScale = minimumZoom
        view.addSubview(scrollView)

        imageView.contentMode = .ScaleAspectFill
        let width = UIScreen.mainScreen().bounds.width
        let height = width - 40.0
        let size = CGSize(width: width, height: height)
        let imageFilter = AspectScaledToFitSizeFilter(size: size)

        imageView.af_setImageWithURL(URL, placeholderImage: nil, filter: imageFilter, imageTransition: .None, runImageTransitionIfCached: false, completion: nil)
        scrollView.addSubview(imageView)
    }

    func configureLayout() {
        if CGRectEqualToRect(scrollView.frame, .zero) {
            scrollView.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height)
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: originalRect.width, height: originalRect.height)

            scrollView.contentSize = imageView.bounds.size

            centerScrollViewContents()

            scrollView.center = CGPoint(x: originalRect.midX, y: originalRect.midY)
        }
    }

    func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0.0
        var verticalInset: CGFloat = 0.0

        if scrollView.contentSize.width < scrollView.bounds.width {
            horizontalInset = (scrollView.bounds.width - scrollView.contentSize.width) / 2.0
        }

        if scrollView.contentSize.height < scrollView.bounds.height {
            verticalInset = (scrollView.bounds.height - scrollView.contentSize.height) / 2.0
        }

        if scrollView.window?.screen.scale < 2.0 {
            horizontalInset = floor(horizontalInset)
            verticalInset = floor(verticalInset)
        }

        // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }

    @objc func handleTap() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)

        scrollView.setZoomScale(minimumZoom, animated: true)
    }

    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.locationInView(view)

        switch gesture.state {
        case .Began:
            interactionController = UIPercentDrivenInteractiveTransition()
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            scrollView.center.x += (location.x - previousLocation.x)
            scrollView.center.y += (location.y - previousLocation.y)

            let delta = fabs(scrollView.frame.midY - view.frame.midY)
            let percent = min(delta / view.frame.midY, 100.0)

            interactionController?.updateInteractiveTransition(percent)
        case .Ended: fallthrough
        case .Cancelled: fallthrough
        case .Failed:
            let velocity = gesture.velocityInView(gesture.view)

            if fabs(velocity.x) > 150.0 || fabs(velocity.y) > 150.0 {
                interactionController?.finishInteractiveTransition()
            }
            else {
                interactionController?.cancelInteractiveTransition()
            }

            interactionController = nil
        default:
            break
        }

        previousLocation = location
    }
}

// MARK: - UIScrollViewDelegate

extension ImageViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()

        panGesture.enabled = (scrollView.zoomScale == minimumZoom)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ImageViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = ImageAnimationController()
        animationController.positive = true

        return animationController
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = ImageAnimationController()
        animationController.positive = false

        return animationController
    }

    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
