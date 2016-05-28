//
//  BuyHeaderViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import SwiftyMarkdown

struct BuyHeaderViewModel {
    let title: String
    let titleAttributedString: NSAttributedString
    let buyButtonTitle: String
    let buyButtonAttributedString: NSAttributedString
    let theme: Theme

    init(deal: Deal?) {
        title = deal?.title ?? "No Title"

        let titleMarkdown = SwiftyMarkdown.markdownWithString(title, fontSize: 20.0)
        titleAttributedString = titleMarkdown.attributedString().attributedStringByApplyingLineBreakMode(.ByWordWrapping, alignment: .Center)

        if let _ = deal?.soldOutDate {
            buyButtonTitle = "Sold Out"
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

        theme = deal?.theme ?? Theme()

        let buyButtonTitleColor = theme.backgroundColor ?? UIColor.blackColor()
        let buyButtonTitleMarkdown = SwiftyMarkdown.markdownWithString(buyButtonTitle, fontSize: 50.0, color: buyButtonTitleColor)
        buyButtonAttributedString = buyButtonTitleMarkdown.attributedString()
    }
}
