//
//  ParagraphCell.swift
//  Meh
//
//  Created by Bradley Smith on 6/12/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

typealias LinkHandlerBlock = (NSURL) -> Void

class ParagraphCell: UICollectionViewCell {
    private let paragraphLabel = LinkLabel(frame: .zero)

    private var topConstraint: NSLayoutConstraint?

    var linkHandler: LinkHandlerBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)

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

extension ParagraphCell {
    func configureWithViewModel(viewModel: ParagraphViewModelProtocol) {
        topConstraint?.constant = viewModel is ParagraphViewModel ? 0.0 : 20.0

        backgroundColor = viewModel.theme.accentColor
//        paragraphLabel.linkColor = viewModel.theme.accentColor
        paragraphLabel.attributedString = viewModel.attributedString
    }
}

// MARK: - Private

private extension ParagraphCell {
    func configureViews() {
        paragraphLabel.numberOfLines = 0
        paragraphLabel.delegate = self
        paragraphLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(paragraphLabel)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            paragraphLabel.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20.0),
            paragraphLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20.0),
            contentView.trailingAnchor.constraintEqualToAnchor(paragraphLabel.trailingAnchor, constant: 20.0),
            contentView.bottomAnchor.constraintEqualToAnchor(paragraphLabel.bottomAnchor, constant: 20.0)
        ]

        topConstraint = constraints.first

        NSLayoutConstraint.activateConstraints(constraints)
    }
}

// MARK: - Static

extension ParagraphCell {
    static func heightWithViewModel(viewModel: ParagraphViewModelProtocol, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 40.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let height = viewModel.attributedString.heightForSize(size)
        let top = CGFloat(viewModel is ParagraphViewModel ? 0.0 : 20.0)

        return top + height + 20.0
    }
}

// MARK: - LinkLabelDelegate

extension ParagraphCell: LinkLabelDelegate {
    func linkLabel(linkLabel: LinkLabel, didSelectLinkWithURL URL: NSURL) {
        linkHandler?(URL)
    }
}
