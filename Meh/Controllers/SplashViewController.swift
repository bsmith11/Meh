//
//  SplashViewController.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import Shimmer

class SplashViewController: UIViewController {
    private let shimmerView = FBShimmeringView(frame: .zero)

    private var didAppear = false

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.whiteColor()

        configureViews()
        configureLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        shimmerView.shimmering = true
    }
}

// MARK: - Public

extension SplashViewController {
    func startAnimating() {
        shimmerView.shimmering = true
    }

    func stopAnimating() {
        shimmerView.shimmering = false
    }
}

// MARK: - Private

private extension SplashViewController {
    func configureViews() {
        let image = UIImage(named: "meh_logo")!
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .Center
        imageView.image = image

        shimmerView.contentView = imageView
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shimmerView)
    }

    func configureLayout() {
        let width = (shimmerView.contentView as? UIImageView)?.image?.size.width ?? 0.0
        let height = (shimmerView.contentView as? UIImageView)?.image?.size.height ?? 0.0

        let constraints: [NSLayoutConstraint] = [
            shimmerView.widthAnchor.constraintEqualToConstant(width),
            shimmerView.heightAnchor.constraintEqualToConstant(height),
            shimmerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
            shimmerView.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 120.0)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}
