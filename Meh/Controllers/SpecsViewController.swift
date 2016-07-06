//
//  SpecsViewController.swift
//  Meh
//
//  Created by Bradley Smith on 5/30/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import SafariServices

class SpecsViewController: UIViewController {
    private let viewModel: SpecsViewModel
    private let scrollView = UIScrollView(frame: .zero)
    private let scrollViewContentView = UIView(frame: .zero)
    private let specsLabel = LinkLabel(frame: .zero)

    private var interactionController: UIPercentDrivenInteractiveTransition?

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    init(viewModel: SpecsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = self
        modalPresentationStyle = .Custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = viewModel.theme.backgroundColor

        configureViews()
        configureLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        specsLabel.attributedString = viewModel.specsAttributedString

        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SpecsViewController.handlePan(_:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
}

// MARK: - Private

private extension SpecsViewController {
    func configureViews() {
        scrollView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 20.0, right: 0.0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        scrollViewContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollViewContentView)

        specsLabel.numberOfLines = 0
        specsLabel.delegate = self
        specsLabel.linkColor = viewModel.theme.accentColor
        specsLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContentView.addSubview(specsLabel)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 20.0),
            view.trailingAnchor.constraintEqualToAnchor(scrollView.trailingAnchor, constant: 20.0),
            view.bottomAnchor.constraintEqualToAnchor(scrollView.bottomAnchor),

            scrollViewContentView.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor, multiplier: 1.0),
            scrollViewContentView.topAnchor.constraintEqualToAnchor(scrollView.topAnchor),
            scrollViewContentView.leadingAnchor.constraintEqualToAnchor(scrollView.leadingAnchor),
            scrollView.trailingAnchor.constraintEqualToAnchor(scrollViewContentView.trailingAnchor),
            scrollView.bottomAnchor.constraintEqualToAnchor(scrollViewContentView.bottomAnchor),

            specsLabel.topAnchor.constraintEqualToAnchor(scrollViewContentView.topAnchor),
            specsLabel.leadingAnchor.constraintEqualToAnchor(scrollViewContentView.leadingAnchor),
            scrollViewContentView.trailingAnchor.constraintEqualToAnchor(specsLabel.trailingAnchor),
            scrollViewContentView.bottomAnchor.constraintEqualToAnchor(specsLabel.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

    func handleURL(URL: NSURL) {
        let safariViewController = SFSafariViewController(URL: URL)
        presentViewController(safariViewController, animated: true, completion: nil)
    }

    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translationInView(gestureRecognizer.view)

        switch gestureRecognizer.state {
        case .Began:
            interactionController = UIPercentDrivenInteractiveTransition()
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            var percentComplete = translation.x / view.bounds.width
            percentComplete = max(0.0, percentComplete)
            percentComplete = min(1.0, percentComplete)

            if interactionController?.percentComplete != percentComplete {
                interactionController?.updateInteractiveTransition(percentComplete)
            }
        case .Ended:
            let velocity = gestureRecognizer.velocityInView(gestureRecognizer.view)

            if velocity.x > 200.0 {
                interactionController?.finishInteractiveTransition()
            }
            else if velocity.x < -200.0 {
                interactionController?.cancelInteractiveTransition()
            }
            else if interactionController?.percentComplete > 0.5 {
                interactionController?.finishInteractiveTransition()
            }
            else {
                interactionController?.cancelInteractiveTransition()
            }

            interactionController = nil
        case .Failed: fallthrough
        case .Cancelled:
            interactionController?.cancelInteractiveTransition()
            interactionController = nil
        default: break
        }
    }
}

// MARK: - LinkLabelDelegate

extension SpecsViewController: LinkLabelDelegate {
    func linkLabel(linkLabel: LinkLabel, didSelectLinkWithURL URL: NSURL) {
        handleURL(URL)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension SpecsViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let slideAnimationController = SlideAnimationController()
        slideAnimationController.positive = true
        slideAnimationController.interactive = interactionController != nil

        return slideAnimationController
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let slideAnimationController = SlideAnimationController()
        slideAnimationController.positive = false
        slideAnimationController.interactive = interactionController != nil

        return slideAnimationController
    }

    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
