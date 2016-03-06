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

        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.lineBreakMode = .ByWordWrapping

        let titleAttributes = [
            NSFontAttributeName: UIFont.storyTitleFont(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSParagraphStyleAttributeName: titleParagraphStyle
        ]

        titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)

        let body = deal?.story?.body ?? "No Body"

        let bodyParagraphStyle = NSMutableParagraphStyle()
        bodyParagraphStyle.lineBreakMode = .ByWordWrapping

        let bodyAttributes = [
            NSFontAttributeName: UIFont.storyBodyFont(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSParagraphStyleAttributeName: bodyParagraphStyle
        ]

        bodyLabel.attributedText = NSAttributedString(string: body, attributes: bodyAttributes)
    }

    static func heightWithDeal(deal: Deal?, width: CGFloat) -> CGFloat {
        let constrainedWidth = width - 40.0
        let size = CGSize(width: constrainedWidth, height: CGFloat.max)
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]

        let title = deal?.story?.title ?? "No Title"

        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.lineBreakMode = .ByWordWrapping

        let titleAttributes = [
            NSFontAttributeName: UIFont.storyTitleFont(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSParagraphStyleAttributeName: titleParagraphStyle
        ]

        let titleBoundingRect = (title as NSString).boundingRectWithSize(size, options: options, attributes: titleAttributes, context: nil)

        let body = deal?.story?.body ?? "No Body"

        let bodyParagraphStyle = NSMutableParagraphStyle()
        bodyParagraphStyle.lineBreakMode = .ByWordWrapping

        let bodyAttributes = [
            NSFontAttributeName: UIFont.storyBodyFont(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSParagraphStyleAttributeName: bodyParagraphStyle
        ]

        let bodyBoundingRect = (body as NSString).boundingRectWithSize(size, options: options, attributes: bodyAttributes, context: nil)

        return ceil(titleBoundingRect.height) + 20.0 + ceil(bodyBoundingRect.height) + 40.0
    }
}
