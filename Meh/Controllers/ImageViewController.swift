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

protocol ImageViewControllerDelegate {
    func imageViewControllerWillStartPresentAnimation(imageViewController: ImageViewController)
    func imageViewControllerDidFinishDismissAnimation(imageViewController: ImageViewController)
}

class ImageViewController: UIViewController {

    // MARK: - Properties

    private let minimumZoom: CGFloat = 1.0
    private let maximumZoom: CGFloat = 2.0

    private let URL: NSURL
    private let originalRect: CGRect
    private let originalAlpha: CGFloat
    private let backgroundView = UIVisualEffectView(effect: nil)
    private let scrollView = UIScrollView(frame: CGRect.zero)
    private let imageView = UIImageView(frame: CGRect.zero)
    private let panGesture = UIPanGestureRecognizer(target: nil, action: nil)

    private var isDismissing = false
    private var animationCount = 0
    private var previousLocation = CGPoint.zero
    private var timeOffset = 0.0

    var delegate: ImageViewControllerDelegate?

    // MARK: - Lifecycle

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    init(URL: NSURL, originalRect: CGRect, originalAlpha: CGFloat) {
        self.URL = URL
        self.originalRect = originalRect
        self.originalAlpha = originalAlpha

        super.init(nibName: nil, bundle: nil)
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

        panGesture.addTarget(self, action: "handlePan:")
        scrollView.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap")
        view.addGestureRecognizer(tapGesture)

        scrollView.alpha = originalAlpha
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        configureLayout()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        delegate?.imageViewControllerWillStartPresentAnimation(self)

        performPresentAnimation(true)
    }

    // MARK: - Setup

    private func configureViews() {
        view.addSubview(backgroundView)

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
        let imageFilter = AspectScaledToFitSizeFilter.init(size: size)

        imageView.af_setImageWithURL(URL, placeholderImage: nil, filter: imageFilter, imageTransition: .None, runImageTransitionIfCached: false, completion: nil)
        scrollView.addSubview(imageView)
    }

    private func configureLayout() {
        if CGRectEqualToRect(scrollView.frame, CGRect.zero) {
            backgroundView.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height)
            scrollView.frame = CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: view.bounds.height)
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: originalRect.width, height: originalRect.height)

            scrollView.contentSize = imageView.bounds.size

            centerScrollViewContents()

            scrollView.center = CGPoint(x: originalRect.midX, y: originalRect.midY)
        }
    }

    // MARK: - Actions

    private func centerScrollViewContents() {
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

    func handleTap() {
        timeOffset = 0.0
        performDismissAnimation(true)

        scrollView.setZoomScale(minimumZoom, animated: true)
    }

    func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.locationInView(view)
        let deltaX = location.x - previousLocation.x
        let deltaY = location.y - previousLocation.y

        switch gesture.state {
        case .Began:
//            UIView.animateWithDuration(0.75, animations: { () -> Void in
//                self.backgroundView.effect = nil
//                self.backgroundView.layer.speed = 0.0
//                self.backgroundView.layer.timeOffset = 0.0
//                }, completion: { _ -> Void in
//                    self.backgroundView.layer.speed = 1.0
//                    self.backgroundView.layer.timeOffset = 0.0
//            })

            break
        case .Changed:
            scrollView.center.x += deltaX
            scrollView.center.y += deltaY

            let delta = fabs(scrollView.center.y - view.center.y)
            let percent = min(delta / view.frame.midY, 100.0)

            backgroundView.layer.timeOffset = Double(percent)
        case .Ended: fallthrough
        case .Cancelled: fallthrough
        case .Failed:
//            timeOffset = backgroundView.layer.timeOffset
//            backgroundView.layer.timeOffset = 1.0

            let velocity = gesture.velocityInView(gesture.view)

            if fabs(velocity.x) > 150.0 || fabs(velocity.y) > 150.0 {
                performDismissAnimationWithVelocity(velocity, animateBackground: true)
//                backgroundView.layer.speed = 1.0
            }
            else {
                performPresentAnimation(true)
//                backgroundView.layer.removeAllAnimations()
//                backgroundView.layer.timeOffset = 0.0
//                backgroundView.layer.speed = 1.0
            }
        default:
            break
        }

        previousLocation = location
    }

    // MARK: - Animations

    private func animateCenter(center: CGPoint, view: UIView) {
        var animation = view.pop_animationForKey("center") as? POPSpringAnimation
        if animation == nil {
            animation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        }

        animation!.toValue = NSValue(CGPoint: center)
        animation!.delegate = self

        view.pop_addAnimation(animation, forKey: "center")
    }

    private func animateAlpha(alpha: CGFloat, view: UIView) {
        var animation = view.pop_animationForKey("alpha") as? POPSpringAnimation
        if animation == nil {
            animation = POPSpringAnimation(propertyNamed: kPOPViewAlpha)
        }

        animation!.toValue = NSNumber(double: Double(alpha))
        animation!.delegate = self

        view.pop_addAnimation(animation, forKey: "alpha")
    }

    private func performPresentAnimation(animateBackground: Bool) {
        view.userInteractionEnabled = false

        animateCenter(view.center, view: scrollView)
        animateAlpha(1.0, view: scrollView)

        if animateBackground {
            UIView.animateWithDuration(0.3) { () -> Void in
                self.backgroundView.effect = UIBlurEffect(style: .Dark)
//                self.backgroundView.layer.timeOffset = self.timeOffset
            }
        }

        animationCount = 2
    }

    private func performDismissAnimation(animateBackground: Bool) {
        performDismissAnimationWithVelocity(CGPoint.zero, animateBackground: animateBackground)
    }

    private func performDismissAnimationWithVelocity(velocity: CGPoint, animateBackground: Bool) {
        view.userInteractionEnabled = false
        isDismissing = true

        let center = CGPoint(x: originalRect.midX, y: originalRect.midY)
        animateCenter(center, view: scrollView)
        animateAlpha(originalAlpha, view: scrollView)

        if animateBackground {
            UIView.animateWithDuration(0.3) { () -> Void in
                self.backgroundView.effect = nil
//                self.backgroundView.layer.timeOffset = self.timeOffset
            }
        }

        animationCount = 2
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

// MARK: - POPAnimationDelegate

extension ImageViewController: POPAnimationDelegate {
    func pop_animationDidStop(anim: POPAnimation!, finished: Bool) {
        animationCount = animationCount - 1

        if animationCount == 0 {
            if isDismissing {
                delegate?.imageViewControllerDidFinishDismissAnimation(self)
            }
            else {
                view.userInteractionEnabled = true
            }
        }
    }
}
