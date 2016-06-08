//
//  TitleHeaderViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 6/7/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct TitleHeaderViewModel {
    private let titles = [
        "Sold Out",
        "Gone",
        "Too Late",
        "Too Slow"
    ]

    let title: String
    let titleAttributedString: NSAttributedString
    let theme: Theme

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        if let _ = deal?.soldOutDate {
            let randomIndex = Int(arc4random_uniform(UInt32(titles.count)))
            title = titles[randomIndex]
        }
        else if let prices = deal?.prices where !prices.isEmpty {
            var lowestPrice = Int.max
            var highestPrice = 0

            for price in prices {
                lowestPrice = min(lowestPrice, price)
                highestPrice = max(highestPrice, price)
            }

            if lowestPrice == highestPrice {
                title = "$" + String(lowestPrice)
            }
            else {
                title = "$" + String(lowestPrice) + " - $" + String(highestPrice)
            }
        }
        else {
            title = "No Price"
        }

        let titleMarkdownParser = TSMarkdownParser.parserWithFontSize(30.0, color: theme.accentColor)
        titleAttributedString = titleMarkdownParser.attributedStringFromMarkdown(title)
    }
}
