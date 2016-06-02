//
//  FeaturesCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

typealias FeaturesCellLinkHandlerBlock = (NSURL) -> Void

class FeaturesCell: UICollectionViewCell {
    private let textLabel = LinkLabel(frame: .zero)

    var linkHandler: FeaturesCellLinkHandlerBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()

        configureViews()
        configureLayout()

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension FeaturesCell {
    func configureWithViewModel(viewModel: FeaturesViewModel) {
        textLabel.linkColor = viewModel.theme.accentColor
        textLabel.attributedString = viewModel.featuresAttributedString
    }
}

// MARK: - Private

private extension FeaturesCell {
    func configureViews() {
        textLabel.numberOfLines = 0
        textLabel.delegate = self
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            textLabel.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 0.0),
            textLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20.0),
            contentView.trailingAnchor.constraintEqualToAnchor(textLabel.trailingAnchor, constant: 20.0),
            contentView.bottomAnchor.constraintEqualToAnchor(textLabel.bottomAnchor, constant: 20.0)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}

// MARK: - Static

extension FeaturesCell {
    static func heightWithViewModel(viewModel: FeaturesViewModel, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 40.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let featuresHeight = viewModel.featuresAttributedString.heightForSize(size)

        return featuresHeight + 20.0
    }
}

// MARK: - LinkLabelDelegate

extension FeaturesCell: LinkLabelDelegate {
    func linkLabel(linkLabel: LinkLabel, didSelectLinkWithURL URL: NSURL) {
        linkHandler?(URL)
    }
}
