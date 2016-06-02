//
//  SpecsViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/30/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct SpecsViewModel {
    let title: String
    let titleAttributedString: NSAttributedString
    let specs: String
    let specsAttributedString: NSAttributedString
    let theme: Theme

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        title = "Specifications"

        let attributes = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.mehFontWithSize(30.0, style: .Bold)
        ]

        titleAttributedString = NSAttributedString(string: title, attributes: attributes)

        specs = deal?.specifications ?? "No Specifications"

        let specsMarkdownParser = TSMarkdownParser.parserWithFontSize(16.0, color: theme.foregroundColor)
        specsAttributedString = specsMarkdownParser.attributedStringFromMarkdown(specs)
    }
}
