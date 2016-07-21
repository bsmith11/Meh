//
//  TableCell.swift
//  Meh
//
//  Created by Bradley Smith on 7/14/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class TableCell: UICollectionViewCell {
    private let contentStackView = UIStackView(frame: .zero)
    private let contentBackgroundView = UIView(frame: .zero)

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

extension TableCell {
    func configureWithViewModel(viewModel: TableViewModel) {
        backgroundColor = viewModel.theme.accentColor

        contentStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})

        for row in viewModel.rows {
            let rowStackView = UIStackView(frame: .zero)
            rowStackView.axis = .Horizontal
            rowStackView.distribution = .FillEqually
            rowStackView.spacing = 1.0

            for attributedString in row {
                let label = UILabel(frame: .zero)
                label.backgroundColor = viewModel.theme.accentColor
                label.numberOfLines = 0
                label.attributedText = attributedString
                rowStackView.addArrangedSubview(label)
            }

            contentStackView.addArrangedSubview(rowStackView)
        }
    }
}

// MARK: - Private

private extension TableCell {
    func configureViews() {
        contentStackView.axis = .Vertical
        contentStackView.spacing = 1.0
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)

        contentBackgroundView.backgroundColor = UIColor.blackColor()
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addSubview(contentBackgroundView)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            contentStackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20.0),
            contentStackView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20.0),
            contentView.trailingAnchor.constraintEqualToAnchor(contentStackView.trailingAnchor, constant: 20.0),
            contentView.bottomAnchor.constraintEqualToAnchor(contentStackView.bottomAnchor, constant: 0.0),

            contentBackgroundView.topAnchor.constraintEqualToAnchor(contentStackView.topAnchor),
            contentBackgroundView.leadingAnchor.constraintEqualToAnchor(contentStackView.leadingAnchor, constant: -1.0),
            contentStackView.trailingAnchor.constraintEqualToAnchor(contentBackgroundView.trailingAnchor, constant: -1.0),
            contentStackView.bottomAnchor.constraintEqualToAnchor(contentBackgroundView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}

// MARK: - Static

extension TableCell {
    static func heightWithViewModel(viewModel: TableViewModel, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 40.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)

        let height = viewModel.rows.reduce(0.0) { (totalMax: CGFloat, row: [NSAttributedString]) -> CGFloat in
            return totalMax + row.reduce(0.0, combine: { (rowMax: CGFloat, attributedString: NSAttributedString) -> CGFloat in
                return max(rowMax, attributedString.heightForSize(size))
            })
        }

        return 20.0 + height
    }
}
