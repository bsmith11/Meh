//
//  StoryCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class StoryCell: UICollectionViewCell {

    // MARK: - Properties

    private let titleLabel = UILabel(frame: CGRect.zero)
    private let bodyLabel = UILabel(frame: CGRect.zero)

    private static var titleAttributes: Dictionary<String, AnyObject> {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping

            let attributes = [
                NSFontAttributeName: UIFont.storyTitleFont(),
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSParagraphStyleAttributeName: paragraphStyle
            ]

            return attributes
        }
    }

    private static var bodyAttributes: Dictionary<String, AnyObject> {
        get {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .ByWordWrapping

            let attributes = [
                NSFontAttributeName: UIFont.storyBodyFont(),
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
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyLabel)
    }

    private func configureLayout() {
        let titleLabelConstraints: [NSLayoutConstraint] = [
            titleLabel.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 20.0),
            titleLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20.0),
            contentView.trailingAnchor.constraintEqualToAnchor(titleLabel.trailingAnchor, constant: 20.0)
        ]

        NSLayoutConstraint.activateConstraints(titleLabelConstraints)

        let bodyLabelConstraints: [NSLayoutConstraint] = [
            bodyLabel.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 20.0),
            bodyLabel.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor, constant: 20.0),
            contentView.trailingAnchor.constraintEqualToAnchor(bodyLabel.trailingAnchor, constant: 20.0),
            contentView.bottomAnchor.constraintEqualToAnchor(bodyLabel.bottomAnchor, constant: 20.0)
        ]

        NSLayoutConstraint.activateConstraints(bodyLabelConstraints)
    }

    func configureWithDeal(deal: Deal?) {
        let title = deal?.story?.title ?? "No Title"

        titleLabel.attributedText = NSAttributedString(string: title, attributes: StoryCell.titleAttributes)

        let body = deal?.story?.body ?? "No Body"

        bodyLabel.attributedText = NSAttributedString(string: body, attributes: StoryCell.bodyAttributes)
    }

    static func heightWithDeal(deal: Deal?, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 40.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let options: NSStringDrawingOptions = .UsesLineFragmentOrigin

        let title: NSString = deal?.story?.title ?? "No Title"
        let titleBoundingRect = title.boundingRectWithSize(size, options: options, attributes: titleAttributes, context: nil)

        let body: NSString = deal?.story?.body ?? "No Body"
        let bodyBoundingRect = body.boundingRectWithSize(size, options: options, attributes: bodyAttributes, context: nil)

        return ceil(titleBoundingRect.height) + 20.0 + ceil(bodyBoundingRect.height) + 40.0
    }
}
