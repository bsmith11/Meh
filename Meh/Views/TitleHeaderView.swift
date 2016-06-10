//
//  TitleHeaderView.swift
//  Meh
//
//  Created by Bradley Smith on 6/7/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import pop

class TitleHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension TitleHeaderView {
    func configureWithViewModel(viewModel: TitleHeaderViewModel) {
        titleLabel.attributedText = viewModel.titleAttributedString
        backgroundColor = viewModel.theme.backgroundColor
    }

    func bounceTitle() {
        if let animation = titleLabel.pop_animationForKey("bounce") as? POPSpringAnimation {
            titleLabel.pop_addAnimation(animation, forKey: "bounce")
        }
        else {
            let animation = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
            animation.velocity = 485.0
            animation.springBounciness = 20.0
            animation.springSpeed = 20.0

            titleLabel.pop_addAnimation(animation, forKey: "bounce")
        }
    }
}

// MARK: - Private

private extension TitleHeaderView {
    func configureViews() {
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: 10.0),
            titleLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 20.0),
            trailingAnchor.constraintEqualToAnchor(titleLabel.trailingAnchor, constant: 20.0 + 50.0 + 20.0),
            bottomAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 10.0)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}

// MARK: - Static

extension TitleHeaderView {
    static func heightWithViewModel(viewModel: TitleHeaderViewModel, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - (20.0 + 20.0 + 50.0 + 20.0)
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let titleHeight = viewModel.titleAttributedString.heightForSize(size)

        return 10.0 + titleHeight + 10.0
    }
}
