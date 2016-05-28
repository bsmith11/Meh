//
//  StoryCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class StoryCell: UICollectionViewCell {
    private let contentStackView = UIStackView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let bodyLabel = UILabel(frame: .zero)

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
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)

        titleLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(titleLabel)

        bodyLabel.numberOfLines = 0
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
        let options: NSStringDrawingOptions = [.UsesFontLeading, .UsesLineFragmentOrigin]

        let titleBoundingRect = viewModel.titleAttributedString.boundingRectWithSize(size, options: options, context: nil)
        let titleHeight = ceil(titleBoundingRect.height)

        let bodyBoundingRect = viewModel.bodyAttributedString.boundingRectWithSize(size, options: options, context: nil)
        let bodyHeight = ceil(bodyBoundingRect.height)

        return 20.0 + titleHeight + bodyHeight + 20.0
    }
}
