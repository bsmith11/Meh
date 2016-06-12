//
//  ErrorView.swift
//  Meh
//
//  Created by Bradley Smith on 6/1/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    private let contentStackView = UIStackView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let messageLabel = UILabel(frame: .zero)
    private let button = UIButton(type: .System)

    var actionHandler: ErrorActionHandler?

    static let bounceAdjustmentHeight = CGFloat(50.0)

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    init(error: NSError) {
        super.init(frame: .zero)

        commonInit()

        configureWithError(error)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public

extension ErrorView {
    func configureWithError(error: NSError) {
        titleLabel.text = error.title
        messageLabel.text = error.message
    }
}

// MARK: - Private

private extension ErrorView {
    func commonInit() {
        backgroundColor = UIColor.blackColor()

        configureViews()
        configureLayout()
    }

    func configureViews() {
        contentStackView.axis = .Vertical
        contentStackView.alignment = .Center
        contentStackView.spacing = 20.0
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStackView)

        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.mehFontWithSize(24.0, style: .Regular)
        titleLabel.textColor = UIColor.whiteColor()
        contentStackView.addArrangedSubview(titleLabel)

        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.mehFontWithSize(20.0, style: .Regular)
        messageLabel.textColor = UIColor.whiteColor()
        contentStackView.addArrangedSubview(messageLabel)

        let highlightEvents: UIControlEvents = [.TouchDown, .TouchDragEnter]
        let unhighlightEvents: UIControlEvents = [.TouchCancel, .TouchDragExit, .TouchUpInside]
        button.addTarget(self, action: #selector(ErrorView.didHighlightButton), forControlEvents: highlightEvents)
        button.addTarget(self, action: #selector(ErrorView.didUnhighlightButton), forControlEvents: unhighlightEvents)
        button.addTarget(self, action: #selector(ErrorView.didTapButton), forControlEvents: .TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            contentStackView.topAnchor.constraintEqualToAnchor(topAnchor, constant: 20.0),
            contentStackView.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 20.0),
            trailingAnchor.constraintEqualToAnchor(contentStackView.trailingAnchor, constant: 20.0),
            bottomAnchor.constraintEqualToAnchor(contentStackView.bottomAnchor, constant: 20.0 + ErrorView.bounceAdjustmentHeight),

            button.topAnchor.constraintEqualToAnchor(topAnchor),
            button.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
            trailingAnchor.constraintEqualToAnchor(button.trailingAnchor),
            bottomAnchor.constraintEqualToAnchor(button.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

    @objc func didHighlightButton() {
        messageLabel.textColor = UIColor.grayColor()
    }

    @objc func didUnhighlightButton() {
        messageLabel.textColor = UIColor.whiteColor()
    }

    @objc func didTapButton() {
        actionHandler?()
    }
}
