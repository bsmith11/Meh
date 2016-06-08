//
//  BuyHeaderViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct BuyHeaderViewModel {
    let buyButtonTitle: String
    let buyButtonAttributedString: NSAttributedString
    let theme: Theme

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        if let _ = deal?.soldOutDate {
            buyButtonTitle = "X"
        }
        else {
            buyButtonTitle = "$"
        }

        let buyButtonTitleMarkdownParser = TSMarkdownParser.parserWithFontSize(30.0, color: theme.accentColor)
        buyButtonAttributedString = buyButtonTitleMarkdownParser.attributedStringFromMarkdown(buyButtonTitle)
    }
}
