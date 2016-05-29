//
//  FeaturesCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class FeaturesCell: UICollectionViewCell {
    private let textLabel = UILabel(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()

        configureViews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension FeaturesCell {
    func configureWithViewModel(viewModel: FeaturesViewModel) {
        textLabel.attributedText = viewModel.featuresAttributedString
    }
}

// MARK: - Private

private extension FeaturesCell {
    func configureViews() {
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            textLabel.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20.0),
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

        return 20.0 + featuresHeight + 20.0
    }
}
