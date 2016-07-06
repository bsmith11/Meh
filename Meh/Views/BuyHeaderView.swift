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
    private let buyButton = UIButton(type: .System)

    weak var delegate: BuyHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
        configureLayout()

        layer.cornerRadius = 30.0
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension BuyHeaderView {
    func configureWithViewModel(viewModel: BuyHeaderViewModel) {
        buyButton.setAttributedTitle(viewModel.buyButtonAttributedString, forState: .Normal)
        buyButton.backgroundColor = UIColor.whiteColor()
    }
}

// MARK: - Private

private extension BuyHeaderView {
    func configureViews() {
        buyButton.addTarget(self, action: #selector(BuyHeaderView.didSelectBuyButton), forControlEvents: .TouchUpInside)
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buyButton)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            buyButton.widthAnchor.constraintEqualToConstant(60.0),
            buyButton.heightAnchor.constraintEqualToConstant(60.0),
            buyButton.topAnchor.constraintEqualToAnchor(topAnchor),
            buyButton.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailingAnchor.constraintEqualToAnchor(buyButton.trailingAnchor),
            bottomAnchor.constraintEqualToAnchor(buyButton.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

    @objc func didSelectBuyButton() {
        delegate?.buyHeaderViewDidSelectBuy(self)
    }
}

// MARK: - Static

extension BuyHeaderView {
    static func sizeWithViewModel(viewModel: BuyHeaderViewModel) -> CGSize {
        return CGSize(width: 60.0, height: 60.0)
    }
}
