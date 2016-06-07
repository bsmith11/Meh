//
//  RootViewController.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import pop

class RootViewController: UIViewController {
    private let splashViewController: SplashViewController
    private let dealViewController: DealViewController

    private var displayedViewController: UIViewController?

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return displayedViewController
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        splashViewController = SplashViewController(nibName: nil, bundle: nil)

        let dealViewModel = DealViewModel()
        dealViewController = DealViewController(viewModel: dealViewModel)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        let completion = { (deal: Deal?, error: NSError?) in
            if let error = error {
                print("Failed to fetch deal with error: \(error)")

                self.displayViewController(nil)

                let errorView = ErrorView(error: error)
                errorView.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(errorView)

                let constraints: [NSLayoutConstraint] = [
                    errorView.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor),
                    self.view.trailingAnchor.constraintEqualToAnchor(errorView.trailingAnchor),
                    self.view.bottomAnchor.constraintEqualToAnchor(errorView.bottomAnchor)
                ]

                NSLayoutConstraint.activateConstraints(constraints)

                errorView.setNeedsLayout()
                errorView.layoutIfNeeded()

                self.displayErrorView(errorView, displayed: false, animated: false)
                self.displayErrorView(errorView, displayed: true, animated: true)
            }
            else {
                print("Successfully fetched deal")

                self.displayViewController(self.dealViewController)
            }
        }

        dealViewModel.fetchDealWithCompletion(completion)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        displayViewController(splashViewController)
    }
}

// MARK: - Private

private extension RootViewController {
    func displayViewController(viewController: UIViewController?) {
        if let displayedViewController = displayedViewController {
            displayedViewController.willMoveToParentViewController(nil)
            displayedViewController.view.removeFromSuperview()
            displayedViewController.removeFromParentViewController()
        }

        displayedViewController = viewController

        if let viewController = viewController {
            addChildViewController(viewController)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(viewController.view)

            let constraints: [NSLayoutConstraint] = [
                viewController.view.topAnchor.constraintEqualToAnchor(view.topAnchor),
                viewController.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
                view.trailingAnchor.constraintEqualToAnchor(viewController.view.trailingAnchor),
                view.bottomAnchor.constraintEqualToAnchor(viewController.view.bottomAnchor)
            ]

            NSLayoutConstraint.activateConstraints(constraints)

            viewController.didMoveToParentViewController(self)
        }
    }

    func displayErrorView(errorView: ErrorView, displayed: Bool, animated: Bool) {
        let translation = displayed ? 0.0 : errorView.bounds.height
        let toValue = NSValue(CGSize: CGSize(width: 0.0, height: translation))
        let animation: POPAnimation

        if animated {
            let springAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
            springAnimation.springBounciness = 5.0
            springAnimation.springSpeed = 1.0
            springAnimation.toValue = toValue

            animation = springAnimation
        }
        else {
            let basicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY)
            basicAnimation.duration = 0.0
            basicAnimation.toValue = toValue

            animation = basicAnimation
        }

        errorView.layer.pop_addAnimation(animation, forKey: "display")
    }
}
