//
//  BuyAnimationController.swift
//  Meh
//
//  Created by Bradley Smith on 6/8/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import pop

private struct AssociatedKeys {
    static var viewAssociatedKey = "alpha_view"
}

class BuyAnimationController: NSObject {
    private let duration = 0.5

    var positive = true
    var rect: CGRect = .zero
}

// MARK: - Private

private extension BuyAnimationController {
    func viewFromObject(object: NSObject?) -> UIView {
        if let view = objc_getAssociatedObject(object, &AssociatedKeys.viewAssociatedKey) as? UIView {
            return view
        }
        else {
            let view = UIView(frame: .zero)
            view.backgroundColor = UIColor.whiteColor()
            objc_setAssociatedObject(object, &AssociatedKeys.viewAssociatedKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return view
        }
    }

    func removeViewFromObject(object: NSObject?) {
        objc_setAssociatedObject(object, &AssociatedKeys.viewAssociatedKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
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

        let alphaView = positive ? viewFromObject(toViewController) : viewFromObject(fromViewController)

        if positive {
            toViewController.view.frame = container.bounds
            container.addSubview(toViewController.view)

            alphaView.frame = container.bounds
            container.addSubview(alphaView)
        }

        let maskView: UIView?

        if positive {
            maskView = UIView(frame: rect)
            maskView?.backgroundColor = UIColor.whiteColor()
            maskView?.layer.cornerRadius = rect.height / 2.0
            container.maskView = maskView
        }
        else {
            maskView = container.maskView
        }

        let frameAnimation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        frameAnimation.springBounciness = 0.0
        frameAnimation.toValue = positive ? NSValue(CGRect: toViewController.view.frame) : NSValue(CGRect: rect)
        frameAnimation.completionBlock = { (popAnimation: POPAnimation?, finished: Bool) in
            let completed = !transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(completed)
        }

        let cornerRadiusAnimation = POPSpringAnimation(propertyNamed: kPOPLayerCornerRadius)
        cornerRadiusAnimation.springBounciness = 0.0
        cornerRadiusAnimation.toValue = positive ? 0.0 : rect.height / 2.0

        let alphaAnimation = POPSpringAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation.toValue = positive ? 0.0 : 1.0

        maskView?.pop_addAnimation(frameAnimation, forKey: "frame")
        maskView?.layer.pop_addAnimation(cornerRadiusAnimation, forKey: "cornerRadius")
        alphaView.pop_addAnimation(alphaAnimation, forKey: "alpha")
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
}
