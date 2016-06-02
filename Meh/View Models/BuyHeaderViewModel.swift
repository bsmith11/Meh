//
//  BuyHeaderViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct BuyHeaderViewModel {
    private let soldOutTitles = [
        "Sold Out",
        "Gone",
        "Too Late",
        "Too Slow"
    ]

    let title: String
    let titleAttributedString: NSAttributedString
    let buyButtonTitle: String
    let buyButtonAttributedString: NSAttributedString
    let theme: Theme

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        title = deal?.title ?? "No Title"

        let titleMarkdownParser = TSMarkdownParser.parserWithFontSize(20.0, alignment: .Center, color: theme.foregroundColor)
        titleAttributedString = titleMarkdownParser.attributedStringFromMarkdown(title)

        if let _ = deal?.soldOutDate {
            let randomIndex = Int(arc4random_uniform(UInt32(soldOutTitles.count)))
            buyButtonTitle = soldOutTitles[randomIndex]
        }
        else if let prices = deal?.prices where !prices.isEmpty {
            var lowestPrice = Int.max
            var highestPrice = 0

            for price in prices {
                lowestPrice = min(lowestPrice, price)
                highestPrice = max(highestPrice, price)
            }

            if lowestPrice == highestPrice {
                buyButtonTitle = "$" + String(lowestPrice)
            }
            else {
                buyButtonTitle = "$" + String(lowestPrice) + " - $" + String(highestPrice)
            }
        }
        else {
            buyButtonTitle = "No Price"
        }

        let buyButtonTitleColor = theme.backgroundColor ?? UIColor.blackColor()
        let buyButtonTitleMarkdownParser = TSMarkdownParser.parserWithFontSize(50.0, color: buyButtonTitleColor)
        buyButtonAttributedString = buyButtonTitleMarkdownParser.attributedStringFromMarkdown(buyButtonTitle)
    }
}
