//
//  RootViewController.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

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

        let completion = { [weak self] (deal: Deal?, error: NSError?) in
            if let error = error {
                print("Failed to fetch deal with error: \(error)")
            }
            else if let strongSelf = self {
                strongSelf.displayViewController(strongSelf.dealViewController)
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
    func displayViewController(viewController: UIViewController) {
        if let displayedViewController = displayedViewController {
            displayedViewController.willMoveToParentViewController(nil)
            displayedViewController.view.removeFromSuperview()
            displayedViewController.removeFromParentViewController()
        }

        displayedViewController = viewController

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
