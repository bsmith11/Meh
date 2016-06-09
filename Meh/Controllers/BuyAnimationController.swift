//
//  BuyAnimationController.swift
//  Meh
//
//  Created by Bradley Smith on 6/8/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import pop

class BuyAnimationController: NSObject {
    private let duration = 0.5

    var positive = true
    var rect: CGRect = .zero
}

// MARK: - UIViewControllerAnimatedTransitioning

extension BuyAnimationController: UIViewControllerAnimatedTransitioning {
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let container = transitionContext.containerView(),
            fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                transitionContext.completeTransition(true)
                return
        }

        if positive {
            toViewController.view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(toViewController.view)

            let constraints: [NSLayoutConstraint] = [
                toViewController.view.topAnchor.constraintEqualToAnchor(container.topAnchor),
                toViewController.view.leadingAnchor.constraintEqualToAnchor(container.leadingAnchor),
                container.trailingAnchor.constraintEqualToAnchor(toViewController.view.trailingAnchor),
                container.bottomAnchor.constraintEqualToAnchor(toViewController.view.bottomAnchor)
            ]

            NSLayoutConstraint.activateConstraints(constraints)

            toViewController.view.setNeedsLayout()
            toViewController.view.layoutIfNeeded()
        }

        let maskView: UIView?
        let frameToValue: NSValue
        let cornerRadiusToValue: CGFloat

        if positive {
            maskView = UIView(frame: rect)
            maskView?.backgroundColor = UIColor.whiteColor()
            maskView?.layer.cornerRadius = rect.height / 2.0
            toViewController.view.maskView = maskView

            frameToValue = NSValue(CGRect: toViewController.view.frame)
            cornerRadiusToValue = 0.0
        }
        else {
            maskView = fromViewController.view.maskView

            frameToValue = NSValue(CGRect: rect)
            cornerRadiusToValue = rect.height / 2.0
        }

        let frameAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        frameAnimation.springBounciness = 0.0
        frameAnimation.toValue = frameToValue
        frameAnimation.completionBlock = { (popAnimation: POPAnimation?, finished: Bool) in
            let completed = !transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(completed)
        }

        let cornerRadiusAnimation = POPSpringAnimation(propertyNamed: kPOPLayerCornerRadius)
        cornerRadiusAnimation.springBounciness = 0.0
        cornerRadiusAnimation.toValue = cornerRadiusToValue

        maskView?.pop_addAnimation(frameAnimation, forKey: "frame")
        maskView?.layer.pop_addAnimation(cornerRadiusAnimation, forKey: "cornerRadius")
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
}
