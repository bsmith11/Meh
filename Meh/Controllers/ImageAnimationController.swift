//
//  ImageAnimationController.swift
//  Meh
//
//  Created by Bradley Smith on 3/24/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

private struct AssociatedKeys {
    static var visualEffectViewAssociatedKey = "visual_effect_view"
}

class ImageAnimationController: NSObject {
    private let duration = 0.5

    var positive = true
    var effect = UIBlurEffect(style: .Light)
}

// MARK: - Private

private extension ImageAnimationController {
    func visualEffectViewFromObject(object: NSObject?) -> UIVisualEffectView {
        if let visualEffectView = objc_getAssociatedObject(object, &AssociatedKeys.visualEffectViewAssociatedKey) as? UIVisualEffectView {
            return visualEffectView
        }
        else {
            let visualEffectView = UIVisualEffectView(effect: nil)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            objc_setAssociatedObject(object, &AssociatedKeys.visualEffectViewAssociatedKey, visualEffectView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return visualEffectView
        }
    }

    func removeVisualEffectViewFromObject(object: NSObject?) {
        objc_setAssociatedObject(object, &AssociatedKeys.visualEffectViewAssociatedKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension ImageAnimationController: UIViewControllerAnimatedTransitioning {
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let container = transitionContext.containerView(),
           let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
           let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {

            let object = positive ? toViewController : fromViewController
            let visualEffectView = self.visualEffectViewFromObject(object)

            if positive {
                toViewController.view.frame = fromViewController.view.bounds
                visualEffectView.frame = fromViewController.view.bounds

                container.addSubview(visualEffectView)
                container.addSubview(toViewController.view)

                toViewController.view.setNeedsLayout()
                toViewController.view.layoutIfNeeded()
            }

            let animations = {
                visualEffectView.effect = self.positive ? self.effect : nil
            }

            let completion = { (finished: Bool) in
                if !self.positive {
                    visualEffectView.removeFromSuperview()
                    self.removeVisualEffectViewFromObject(fromViewController)
                }

                let completed = !transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(completed)
            }

            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animations, completion: completion)
        }
        else {
            transitionContext.completeTransition(true)
        }
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
}
