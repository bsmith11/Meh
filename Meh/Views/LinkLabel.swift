//
//  LinkLabel.swift
//  Meh
//
//  Created by Bradley Smith on 5/29/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

protocol LinkLabelDelegate: NSObjectProtocol {
    func linkLabel(linkLabel: LinkLabel, didSelectLinkWithURL URL: NSURL)
}

struct Link {
    let value: AnyObject
    let range: NSRange
}

//
// Based off of https://github.com/TTTAttributedLabel/TTTAttributedLabel
//

class LinkLabel: UILabel {
    static let linkAttributeName = "MehLink"

    private var layoutManager = NSLayoutManager()
    private var textStorage: NSTextStorage?
    private var shouldConfigureLayoutManager = true
    private var links = [Link]()
    private var activeLink: Link? {
        willSet {
            if let activeLink = activeLink {
                if let newValue = newValue where !NSEqualRanges(newValue.range, activeLink.range) {
                    applyLinkColor(linkColor, range: activeLink.range)
                }
                else if newValue == nil {
                    applyLinkColor(linkColor, range: activeLink.range)
                }
            }
        }

        didSet {
            if let activeLink = activeLink {
                applyLinkColor(highlightedLinkColor, range: activeLink.range)
            }
        }
    }

    var attributedString: NSAttributedString? {
        get {
            return attributedText
        }

        set {
            if let newValue = newValue {
                self.links.removeAll()

                let mutableAttributedText = NSMutableAttributedString(attributedString: newValue)
                let range = NSRange(location: 0, length: mutableAttributedText.length)
                let block = { (value: AnyObject?, attributeRange: NSRange, stop: UnsafeMutablePointer<ObjCBool>) in
                    if let value = value {
                        let link = Link(value: value, range: attributeRange)
                        self.links.append(link)

                        mutableAttributedText.addAttribute(NSForegroundColorAttributeName, value: self.linkColor, range: attributeRange)
                        mutableAttributedText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: attributeRange)
                    }
                }

                mutableAttributedText.enumerateAttribute(LinkLabel.linkAttributeName, inRange: range, options: .LongestEffectiveRangeNotRequired, usingBlock: block)

                attributedText = mutableAttributedText
            }
            else {
                attributedText = newValue
            }
        }
    }

    var linkColor = UIColor.blueColor()
    var highlightedLinkColor = UIColor.grayColor()

    weak var delegate: LinkLabelDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        guard containsLinkAtPoint(point) && userInteractionEnabled else {
            return super.hitTest(point, withEvent: event)
        }

        return self
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            activeLink = linkAtPoint(point)

            if activeLink == nil {
                super.touchesBegan(touches, withEvent: event)
            }
        }
        else {
            super.touchesBegan(touches, withEvent: event)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let activeLink = activeLink {
            if let touch = touches.first {
                let point = touch.locationInView(self)
                if let link = linkAtPoint(point) {
                    if !NSEqualRanges(activeLink.range, link.range) {
                        self.activeLink = nil
                    }
                }
            }
        }
        else {
            super.touchesMoved(touches, withEvent: event)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let activeLink = activeLink {
            if let URL = activeLink.value as? NSURL {
                delegate?.linkLabel(self, didSelectLinkWithURL: URL)
            }
            else if let URLString = activeLink.value as? String {
                if let URL = NSURL(string: URLString) {
                    delegate?.linkLabel(self, didSelectLinkWithURL: URL)
                }
            }

            self.activeLink = nil
        }
        else {
            super.touchesEnded(touches, withEvent: event)
        }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let _ = activeLink {
            self.activeLink = nil
        }
        else {
            super.touchesCancelled(touches, withEvent: event)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if shouldConfigureLayoutManager {
            configureLayoutManager()
        }
        else {
            shouldConfigureLayoutManager = true
        }
    }
}

// MARK: - Private

private extension LinkLabel {
    func configureLayoutManager() {
        let size = CGSize(width: bounds.width, height: bounds.height)
        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .ByWordWrapping
        textContainer.maximumNumberOfLines = 0

        layoutManager.usesFontLeading = false

        while !layoutManager.textContainers.isEmpty {
            layoutManager.removeTextContainerAtIndex(0)
        }

        layoutManager.addTextContainer(textContainer)

        textStorage?.removeLayoutManager(layoutManager)

        let attributedString = attributedText ?? NSAttributedString(string: "")
        textStorage = NSTextStorage(attributedString: attributedString)
        textStorage?.addLayoutManager(layoutManager)

        layoutManager.ensureLayoutForTextContainer(textContainer)
    }

    func applyLinkColor(linkColor: UIColor, range: NSRange) {
        if let attributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.addAttribute(NSForegroundColorAttributeName, value: linkColor, range: range)

            shouldConfigureLayoutManager = false

            self.attributedText = mutableAttributedText
        }
    }

    func containsLinkAtPoint(point: CGPoint) -> Bool {
        return linkAtPoint(point) != nil
    }

    func linkAtPoint(point: CGPoint) -> Link? {
        guard CGRectInset(bounds, -15.0, -15.0).contains(point) && !links.isEmpty else {
            return nil
        }

        return linkAtCharacterIndex(characterIndexAtPoint(point))
    }

    func linkAtCharacterIndex(index: Int) -> Link? {
        guard let attributedText = attributedText where NSLocationInRange(index, NSRange(location: 0, length: attributedText.length)) else {
            return nil
        }

        for link in links {
            if NSLocationInRange(index, link.range) {
                return link
            }
        }

        return nil
    }

    func characterIndexAtPoint(point: CGPoint) -> Int {
        guard let textContainer = layoutManager.textContainers.first where bounds.contains(point) else {
            return NSNotFound
        }

        //TODO: Fix index returning valid when tap is on empty space on last line of text
        return layoutManager.characterIndexForPoint(point, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    }
}
