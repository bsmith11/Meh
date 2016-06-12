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
    private let dealViewModel: DealViewModel
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

        dealViewModel = DealViewModel()
        dealViewController = DealViewController(viewModel: dealViewModel)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        fetchDeal()
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

    func fetchDeal() {
        splashViewController.startAnimating()

        let completion = { [weak self] (deal: Deal?, error: NSError?) in
            self?.splashViewController.stopAnimating()

            guard let _ = deal else {
                let dealError: NSError

                if let error = error {
                    dealError = error
                }
                else {
                    dealError = NSError.errorWithCategory(.InvalidResponse)
                }

                ErrorService.displayError(dealError, actionHandler: {
                    self?.fetchDeal()
                })

                return
            }

            self?.displayViewController(self?.dealViewController)
        }

        dealViewModel.fetchDealWithCompletion(completion)
    }
}
