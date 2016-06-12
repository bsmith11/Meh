//
//  ErrorService.swift
//  Meh
//
//  Created by Bradley Smith on 6/12/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import pop

typealias PopAnimationCompletion = (POPAnimation?, Bool) -> Void
typealias ErrorActionHandler = () -> Void

class ErrorService {
    static func displayError(error: NSError, actionHandler: ErrorActionHandler?) {
        if let window = (UIApplication.sharedApplication().delegate as? AppDelegate)?.window {
            let errorView = ErrorView(error: error)
            errorView.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(errorView)

            let constraints: [NSLayoutConstraint] = [
                errorView.leadingAnchor.constraintEqualToAnchor(window.leadingAnchor),
                window.trailingAnchor.constraintEqualToAnchor(errorView.trailingAnchor),
                window.bottomAnchor.constraintEqualToAnchor(errorView.bottomAnchor)
            ]

            NSLayoutConstraint.activateConstraints(constraints)

            errorView.setNeedsLayout()
            errorView.layoutIfNeeded()

            let handler = {
                displayErrorView(errorView, displayed: false, animated: true, completion: { _ in
                    errorView.removeFromSuperview()
                })

                actionHandler?()
            }

            errorView.actionHandler = handler

            displayErrorView(errorView, displayed: false, animated: false, completion: { (animation: POPAnimation?, finished: Bool) in
                displayErrorView(errorView, displayed: true, animated: true, completion: nil)
            })
        }
    }

    static func displayErrorView(errorView: ErrorView, displayed: Bool, animated: Bool, completion: PopAnimationCompletion?) {
        let translation = displayed ? ErrorView.bounceAdjustmentHeight : errorView.bounds.height
        let animation: POPAnimation

        if animated {
            let springAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationY)
            springAnimation.springBounciness = 1.0
            springAnimation.springSpeed = 1.0
            springAnimation.toValue = translation
            springAnimation.completionBlock = completion

            animation = springAnimation
        }
        else {
            let basicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
            basicAnimation.duration = 0.0
            basicAnimation.toValue = translation
            basicAnimation.completionBlock = completion

            animation = basicAnimation
        }

        errorView.layer.pop_addAnimation(animation, forKey: "display")
    }
}
