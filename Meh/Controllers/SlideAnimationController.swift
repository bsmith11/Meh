//
//  SlideAnimationController.swift
//  Meh
//
//  Created by Bradley Smith on 5/30/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class SlideAnimationController: NSObject {
    private let duration = 0.5

    var positive = true
    var interactive = false
}

// MARK: - UIViewControllerAnimatedTransitioning

extension SlideAnimationController: UIViewControllerAnimatedTransitioning {
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let container = transitionContext.containerView(),
                  fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
                  toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            transitionContext.completeTransition(true)
            return
        }

        if positive {
            container.addSubview(toViewController.view)
            toViewController.view.translatesAutoresizingMaskIntoConstraints = false

            let constraints: [NSLayoutConstraint] = [
                toViewController.view.topAnchor.constraintEqualToAnchor(container.topAnchor),
                toViewController.view.leadingAnchor.constraintEqualToAnchor(container.leadingAnchor),
                container.trailingAnchor.constraintEqualToAnchor(toViewController.view.trailingAnchor),
                container.bottomAnchor.constraintEqualToAnchor(toViewController.view.bottomAnchor)
            ]

            NSLayoutConstraint.activateConstraints(constraints)

            toViewController.view.setNeedsLayout()
            toViewController.view.layoutIfNeeded()
            toViewController.view.transform = CGAffineTransformMakeTranslation(toViewController.view.bounds.width, 0.0)
        }

        let animations = { () -> Void in
            if self.positive {
                toViewController.view.transform = CGAffineTransformIdentity
            }
            else {
                fromViewController.view.transform = CGAffineTransformMakeTranslation(fromViewController.view.bounds.width, 0.0)
            }
        }

        let completion = { (finished: Bool) -> Void in
            let completed = !transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(completed)
        }

        if interactive {
            UIView.animateWithDuration(duration, delay: 0.0, options: .CurveLinear, animations: animations, completion: completion)
        }
        else {
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: animations, completion: completion)
        }
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
}
