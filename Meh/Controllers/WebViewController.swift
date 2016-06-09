//
//  WebViewController.swift
//  Meh
//
//  Created by Bradley Smith on 6/8/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import SafariServices

class WebViewController: SFSafariViewController {
    private let rect: CGRect

    init(rect: CGRect, URL: NSURL) {
        self.rect = rect

        super.init(URL: URL, entersReaderIfAvailable: false)

        transitioningDelegate = self
        modalPresentationStyle = .Custom
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension WebViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = BuyAnimationController()
        animationController.positive = true
        animationController.rect = rect

        return animationController
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = BuyAnimationController()
        animationController.positive = false
        animationController.rect = rect

        return animationController
    }
}
