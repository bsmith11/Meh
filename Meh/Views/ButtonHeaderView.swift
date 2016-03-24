//
//  ButtonHeaderView.swift
//  Meh
//
//  Created by Bradley Smith on 3/3/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol ButtonHeaderViewDelegate {
    func didSelectButton()
}

class ButtonHeaderView: UICollectionReusableView {

    // MARK: - Properties

    private let titleLabel = UILabel(frame: CGRect.zero)
    private let button = UIButton(type: .System)
    private var deal: Deal?

    private static var titleAttributes: Dictionary<String, AnyObject> {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping
            paragraphStyle.alignment = .Center

            let attributes = [
                NSFontAttributeName: UIFont.dealTitleFont(),
                NSParagraphStyleAttributeName: paragraphStyle
            ]

            return attributes
        }
    }

    var delegate: ButtonHeaderViewDelegate?

    // MARK: - Lifecycle

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
                    backgroundColor = deal?.theme.backgroundColor
                }
            }
            else {
                if backgroundColor != nil {
                    backgroundColor = nil
                }
            }
        }
    }

    // MARK: - Setup

    func configureViews() {
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        button.addTarget(self, action: "didSelectButton", forControlEvents: .TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
    }

    func configureLayout() {
        let titleLabelConstraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraintEqualToAnchor(topAnchor, constant: 10.0),
            titleLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 10.0),
            trailingAnchor.constraintEqualToAnchor(titleLabel.trailingAnchor, constant: 10.0)
        ]

        NSLayoutConstraint.activateConstraints(titleLabelConstraints)

        let buttonConstraints: [NSLayoutConstraint] = [
            button.heightAnchor.constraintEqualToConstant(64.0),
            button.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 10.0),
            button.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailingAnchor.constraintEqualToAnchor(button.trailingAnchor),
            bottomAnchor.constraintEqualToAnchor(button.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(buttonConstraints)
    }

    func configureWithDeal(deal: Deal?) {
        self.deal = deal

        button.backgroundColor = deal?.theme.accentColor

        let title = deal?.title ?? "No Name"

        var titleAttributes = ButtonHeaderView.titleAttributes
        titleAttributes[NSForegroundColorAttributeName] = deal?.theme.foregroundColor ?? UIColor.blackColor()

        titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)

        var buttonTitle = "No price"

        if let _ = deal?.soldOutDate {
            buttonTitle = "Sold Out"
        }
        else if let prices = deal?.prices {
            if prices.count > 0 {
                var lowestPrice = Int.max
                var highestPrice = 0

                for price in prices {
                    lowestPrice = min(lowestPrice, price)
                    highestPrice = max(highestPrice, price)
                }

                if lowestPrice == highestPrice {
                    buttonTitle = "$" + String(lowestPrice)
                }
                else {
                    buttonTitle = "$" + String(lowestPrice) + " - $" + String(highestPrice)
                }
            }
        }

        let buttonParagraphStyle = NSMutableParagraphStyle()
        buttonParagraphStyle.alignment = .Center

        let buttonAttributes = [
            NSFontAttributeName: UIFont.buyCellFont(),
            NSForegroundColorAttributeName: deal?.theme.backgroundColor ?? UIColor.blackColor(),
            NSParagraphStyleAttributeName: buttonParagraphStyle
        ]

        let attributedTitle = NSAttributedString(string: buttonTitle, attributes: buttonAttributes)
        button.setAttributedTitle(attributedTitle, forState: .Normal)
    }

    // MARK: - Actions

    func didSelectButton() {
        delegate?.didSelectButton()
    }

    static func heightWithDeal(deal: Deal?, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 20.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let options: NSStringDrawingOptions = .UsesLineFragmentOrigin

        let title: NSString = deal?.title ?? "No Name"
        let boundingRect = title.boundingRectWithSize(size, options: options, attributes: titleAttributes, context: nil)
        let titleLabelHeight = ceil(boundingRect.size.height)

        return titleLabelHeight + 20.0 + 64.0
    }
}
