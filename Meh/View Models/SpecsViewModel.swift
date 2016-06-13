//
//  SpecsViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/30/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct SpecsViewModel: ParagraphViewModelProtocol {
    let theme: Theme
    let attributedString: NSAttributedString
    let specsAttributedString: NSAttributedString

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        let title = "Specifications"
        let attributes = [
            NSForegroundColorAttributeName: theme.backgroundColor,
            NSFontAttributeName: UIFont.mehFontWithSize(30.0, style: .Bold)
        ]

        attributedString = NSAttributedString(string: title, attributes: attributes)

        let specs = deal?.specifications ?? "No Specifications"

        let markdownParser = TSMarkdownParser.parserWithFontSize(16.0, color: theme.foregroundColor)
        specsAttributedString = markdownParser.attributedStringFromMarkdown(specs)
    }
}
