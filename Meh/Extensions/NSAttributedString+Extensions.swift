//
//  NSAttributedString+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 4/6/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func attributedStringByApplyingLineBreakMode(lineBreakMode: NSLineBreakMode, headIndent: CGFloat = 0.0, alignment: NSTextAlignment = .Left) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.headIndent = headIndent
        paragraphStyle.alignment = alignment

        let range = NSRange(location: 0, length: mutableAttributedString.length)
        mutableAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)

        return mutableAttributedString
    }
}
