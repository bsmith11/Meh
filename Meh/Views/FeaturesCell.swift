//
//  FeaturesCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class FeaturesCell: UICollectionViewCell {

    // MARK: - Properties

    private let textLabel = UILabel(frame: CGRect.zero)

    private static var textAttributes: Dictionary<String, AnyObject> {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping
            paragraphStyle.headIndent = 10.0

            let attributes = [
                NSFontAttributeName: UIFont.dealFeaturesFont(),
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSParagraphStyleAttributeName: paragraphStyle
            ]

            return attributes
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale

        configureViews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func configureViews() {
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
    }

    private func configureLayout() {
        let textLabelConstraints: [NSLayoutConstraint] = [
            textLabel.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20.0),
            textLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20.0),
            contentView.trailingAnchor.constraintEqualToAnchor(textLabel.trailingAnchor, constant: 20.0),
            contentView.bottomAnchor.constraintEqualToAnchor(textLabel.bottomAnchor, constant: 20.0)
        ]

        NSLayoutConstraint.activateConstraints(textLabelConstraints)
    }

    func configureWithFeatures(features: String?) {
        let text = features ?? "No Features"

        textLabel.attributedText = NSAttributedString(string: text, attributes: FeaturesCell.textAttributes)
    }

    static func heightWithFeatures(features: String?, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 40.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let options: NSStringDrawingOptions = .UsesLineFragmentOrigin

        let text: NSString = features ?? "No Features"
        let boundingRect = text.boundingRectWithSize(size, options: options, attributes: textAttributes, context: nil)

        return ceil(boundingRect.size.height) + 40.0
    }
}
