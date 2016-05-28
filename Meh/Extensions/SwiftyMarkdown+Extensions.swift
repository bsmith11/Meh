//
//  SwiftyMarkdown+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 5/25/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import SwiftyMarkdown

extension SwiftyMarkdown {
    class func markdownWithString(string: String, fontSize: CGFloat, color: UIColor = UIColor.blackColor()) -> SwiftyMarkdown {
        let markdown = SwiftyMarkdown(string: string)
        let bodyFont = UIFont.mehFontWithSize(fontSize, style: .Regular)
        let italicFont = UIFont.mehFontWithSize(fontSize, style: .Italic)
        let boldFont = UIFont.mehFontWithSize(fontSize, style: .Bold)

        markdown.body.fontName = bodyFont.fontName
        markdown.body.fontSize = bodyFont.pointSize
        markdown.body.color = color

        markdown.link.fontName = bodyFont.fontName
        markdown.link.fontSize = bodyFont.pointSize
        markdown.link.color = UIColor.blueColor()

        markdown.bold.fontName = boldFont.fontName
        markdown.bold.fontSize = boldFont.pointSize
        markdown.bold.color = color

        markdown.italic.fontName = italicFont.fontName
        markdown.italic.fontSize = italicFont.pointSize
        markdown.italic.color = color

        markdown.code.fontName = bodyFont.fontName
        markdown.code.fontSize = bodyFont.pointSize
        markdown.code.color = color

        return markdown
    }
}
