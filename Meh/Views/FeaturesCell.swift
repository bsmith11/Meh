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

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()

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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        let attributes = [
            NSFontAttributeName: UIFont.dealFeaturesFont(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]

        textLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
    }

    static func heightWithFeatures(features: String?, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 40.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]

        let text = features ?? "No Features"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        let attributes = [
            NSFontAttributeName: UIFont.dealFeaturesFont(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSParagraphStyleAttributeName: paragraphStyle
        ]

        let boundingRect = (text as NSString).boundingRectWithSize(size, options: options, attributes: attributes, context: nil)

        return ceil(boundingRect.size.height) + 40.0
    }
}
