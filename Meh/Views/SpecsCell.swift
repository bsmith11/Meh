//
//  SpecsCell.swift
//  Meh
//
//  Created by Bradley Smith on 5/30/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class SpecsCell: UICollectionViewCell {
    private let contentStackView = UIStackView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let disclosureImageView = UIImageView(frame: .zero)

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

    override var highlighted: Bool {
        didSet {
            disclosureImageView.alpha = highlighted ? 0.25 : 1.0
        }
    }
}

// MARK: - Public

extension SpecsCell {
    func configureWithViewModel(viewModel: SpecsViewModel) {
        backgroundColor = viewModel.theme.accentColor
        titleLabel.attributedText = viewModel.titleAttributedString
        disclosureImageView.tintColor = viewModel.theme.backgroundColor
    }
}

// MARK: - Private

private extension SpecsCell {
    func configureViews() {
        contentStackView.axis = .Horizontal
        contentStackView.alignment = .Center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)

        titleLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(titleLabel)

        disclosureImageView.image = UIImage(named: "Disclosure Icon")?.imageWithRenderingMode(.AlwaysTemplate)
        disclosureImageView.contentMode = .Center
        disclosureImageView.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        contentStackView.addArrangedSubview(disclosureImageView)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            contentStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20.0),
            contentStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20.0),
            contentView.trailingAnchor.constraintEqualToAnchor(contentStackView.trailingAnchor, constant: 20.0),
            contentView.bottomAnchor.constraintEqualToAnchor(contentStackView.bottomAnchor, constant: 20.0)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}

// MARK: - Static

extension SpecsCell {
    static func heightWithViewModel(viewModel: SpecsViewModel, width: CGFloat) -> CGFloat {
        let constrainedSize = CGSize(width: width, height: CGFloat.max)
        let titleHeight = viewModel.titleAttributedString.heightForSize(constrainedSize)
        let imageHeight = UIImage(named: "Disclosure Icon")?.size.height ?? 0.0
        let height = max(titleHeight, imageHeight)

        return 20.0 + height + 20.0
    }
}
