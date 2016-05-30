//
//  StoryCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

typealias StoryCellLinkHandlerBlock = (NSURL) -> Void

class StoryCell: UICollectionViewCell {
    private let contentStackView = UIStackView(frame: .zero)
    private let titleLabel = LinkLabel(frame: .zero)
    private let bodyLabel = LinkLabel(frame: .zero)

    var linkHandler: StoryCellLinkHandlerBlock?

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

extension StoryCell {
    func configureWithViewModel(viewModel: StoryViewModel) {
        titleLabel.attributedText = viewModel.titleAttributedString
        bodyLabel.attributedText = viewModel.bodyAttributedString
    }
}

// MARK: - Private

private extension StoryCell {
    func configureViews() {
        contentStackView.axis = .Vertical
        contentStackView.spacing = 10.0
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)

        titleLabel.numberOfLines = 0
        titleLabel.delegate = self
        contentStackView.addArrangedSubview(titleLabel)

        bodyLabel.numberOfLines = 0
        bodyLabel.delegate = self
        bodyLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        contentStackView.addArrangedSubview(bodyLabel)
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

extension StoryCell {
    static func heightWithViewModel(viewModel: StoryViewModel, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 40.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let titleHeight = viewModel.titleAttributedString.heightForSize(size)
        let bodyHeight = viewModel.bodyAttributedString.heightForSize(size)

        return 20.0 + titleHeight + 10.0 + bodyHeight + 20.0
    }
}

// MARK: - LinkLabelDelegate

extension StoryCell: LinkLabelDelegate {
    func linkLabel(linkLabel: LinkLabel, didSelectLinkWithURL URL: NSURL) {
        linkHandler?(URL)
    }
}
