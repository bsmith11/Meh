//
//  TSMarkdownParser+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 5/29/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

extension TSMarkdownParser {
    class func parserWithFontSize(fontSize: CGFloat, alignment: NSTextAlignment = .Left, color: UIColor = UIColor.blackColor()) -> TSMarkdownParser {
        let markdownParser = TSMarkdownParser()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment

        markdownParser.defaultAttributes = [
            NSFontAttributeName: UIFont.mehFontWithSize(fontSize, style: .Regular),
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle
        ]

        markdownParser.addStrongParsingWithFormattingBlock { (mutableAttributedString: NSMutableAttributedString, range: NSRange) in
            let font = UIFont.mehFontWithSize(fontSize, style: .Bold)
            mutableAttributedString.addAttribute(NSFontAttributeName, value: font, range: range)
        }

        markdownParser.addEmphasisParsingWithFormattingBlock { (mutableAttributedString: NSMutableAttributedString, range: NSRange) in
            let font = UIFont.mehFontWithSize(fontSize, style: .Italic)
            mutableAttributedString.addAttribute(NSFontAttributeName, value: font, range: range)
        }

        markdownParser.addLinkParsingWithLinkFormattingBlock { (mutableAttributedString: NSMutableAttributedString, range: NSRange, link: String?) in
            let color = UIColor.blueColor()
            mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)

            if let link = link {
                mutableAttributedString.addAttribute(NSLinkAttributeName, value: link, range: range)
            }
        }

        return markdownParser
    }
}
