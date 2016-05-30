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

        let strongBlock = { (mutableAttributedString: NSMutableAttributedString, range: NSRange) in
            let font = UIFont.mehFontWithSize(fontSize, style: .Bold)
            mutableAttributedString.addAttribute(NSFontAttributeName, value: font, range: range)
        }

        markdownParser.addStrongParsingWithFormattingBlock(strongBlock)

        let emphasisBlock = { (mutableAttributedString: NSMutableAttributedString, range: NSRange) in
            let font = UIFont.mehFontWithSize(fontSize, style: .Italic)
            mutableAttributedString.addAttribute(NSFontAttributeName, value: font, range: range)
        }

        markdownParser.addEmphasisParsingWithFormattingBlock(emphasisBlock)

        let linkBlock = { (mutableAttributedString: NSMutableAttributedString, range: NSRange, link: String?) in
            let color = UIColor.blueColor()
            mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)

            if let link = link {
                mutableAttributedString.addAttribute(NSLinkAttributeName, value: link, range: range)
            }
        }

        markdownParser.addLinkParsingWithLinkFormattingBlock(linkBlock)

        let leadBlock = { (mutableAttributedString: NSMutableAttributedString, range: NSRange, level: UInt) in
            let attributes = mutableAttributedString.attributesAtIndex(range.location, longestEffectiveRange: nil, inRange: range)
            let leadString = "\u{2022} "
            let leadAttributedString = NSAttributedString(string: leadString, attributes: attributes)
            let leadStringWidth = leadAttributedString.singleLineWidth()
            let paragraphStyle = mutableAttributedString.attribute(NSParagraphStyleAttributeName, atIndex: range.location, effectiveRange: nil)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()

            paragraphStyle.headIndent = leadStringWidth
            mutableAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
            mutableAttributedString.fixAttributesInRange(range)

            mutableAttributedString.replaceCharactersInRange(range, withString: leadString)
        }

        markdownParser.addListParsingWithMaxLevel(1, leadFormattingBlock: leadBlock, textFormattingBlock: nil)

        return markdownParser
    }
}
