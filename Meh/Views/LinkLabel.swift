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

    private var links = [Link]()
    private var activeLink: Link? {
        willSet {
            if let activeLink = activeLink {
                if let newValue = newValue where !NSEqualRanges(newValue.range, activeLink.range) {
                    applyNormalLinkColorInRange(activeLink.range)
                }
                else if newValue == nil {
                    applyNormalLinkColorInRange(activeLink.range)
                }
            }
        }

        didSet {
            if let activeLink = activeLink {
                applyHighlightedLinkColorInRange(activeLink.range)
            }
        }
    }

    private var normalLinkColor: UIColor?

    var highlightedLinkColor: UIColor? = UIColor.grayColor()

    override var attributedText: NSAttributedString? {
        didSet {
            if let attributedText = attributedText {
                let range = NSRange(location: 0, length: attributedText.length)
                let block = { (value: AnyObject?, attributeRange: NSRange, stop: UnsafeMutablePointer<ObjCBool>) in
                    self.links.removeAll()

                    if let value = value {
                        let link = Link(value: value, range: attributeRange)
                        self.links.append(link)
                    }
                }

                attributedText.enumerateAttribute(LinkLabel.linkAttributeName, inRange: range, options: .LongestEffectiveRangeNotRequired, usingBlock: block)
            }
        }
    }

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
}

// MARK: - Private

private extension LinkLabel {
    func applyNormalLinkColorInRange(range: NSRange) {
        if let linkColor = normalLinkColor {
            applyLinkColor(linkColor, range: range)
        }
    }

    func applyHighlightedLinkColorInRange(range: NSRange) {
        if let previousLinkColor = attributedText?.attribute(NSForegroundColorAttributeName, atIndex: range.location, effectiveRange: nil) as? UIColor {
            normalLinkColor = previousLinkColor
        }

        if let linkColor = highlightedLinkColor {
            applyLinkColor(linkColor, range: range)
        }
    }

    func applyLinkColor(linkColor: UIColor, range: NSRange) {
        if let attributedText = attributedText {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.addAttribute(NSForegroundColorAttributeName, value: linkColor, range: range)
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
        guard let attributedText = attributedText where bounds.contains(point) else {
            return NSNotFound
        }

        //TODO: Fix index returning valid when tap is on empty space on last line of text
        //TODO: Cache TextKit layout stuff instead of recalculating layout each time
        let index = attributedText.characterIndexForPoint(point, bounds: bounds)

        return index
    }
}
