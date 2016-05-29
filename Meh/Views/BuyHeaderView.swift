//
//  BuyHeaderView.swift
//  Meh
//
//  Created by Bradley Smith on 5/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol BuyHeaderViewDelegate: NSObjectProtocol {
    func buyHeaderViewDidSelectBuy(headerView: BuyHeaderView)
}

class BuyHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel(frame: .zero)
    private let buyButton = UIButton(type: .System)

    private var theme: Theme?

    weak var delegate: BuyHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        if let layoutAttributes = layoutAttributes as? HeaderCollectionViewLayoutAttributes {
            if layoutAttributes.isPinned {
                if backgroundColor == nil {
                    backgroundColor = theme?.backgroundColor
                }
            }
            else {
                if backgroundColor != nil {
                    backgroundColor = nil
                }
            }
        }
    }
}

// MARK: - Public

extension BuyHeaderView {
    func configureWithViewModel(viewModel: BuyHeaderViewModel) {
        titleLabel.attributedText = viewModel.titleAttributedString
        buyButton.setAttributedTitle(viewModel.buyButtonAttributedString, forState: .Normal)

        theme = viewModel.theme
        buyButton.backgroundColor = theme?.accentColor
    }
}

// MARK: - Private

private extension BuyHeaderView {
    func configureViews() {
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        buyButton.addTarget(self, action: #selector(BuyHeaderView.didSelectButton), forControlEvents: .TouchUpInside)
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buyButton)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: 10.0),
            titleLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 10.0),
            trailingAnchor.constraintEqualToAnchor(titleLabel.trailingAnchor, constant: 10.0),

            buyButton.heightAnchor.constraintEqualToConstant(64.0),
            buyButton.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 10.0),
            buyButton.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailingAnchor.constraintEqualToAnchor(buyButton.trailingAnchor),
            bottomAnchor.constraintEqualToAnchor(buyButton.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

    @objc func didSelectButton() {
        delegate?.buyHeaderViewDidSelectBuy(self)
    }
}

// MARK: - Static

extension BuyHeaderView {
    static func heightWithViewModel(viewModel: BuyHeaderViewModel, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 20.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let titleHeight = viewModel.titleAttributedString.heightForSize(size)

        return 10.0 + titleHeight + 10.0 + 64.0
    }
}
