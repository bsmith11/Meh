//
//  StoryViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/25/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct StoryViewModel {
    let theme: Theme
    let title: String
    let body: String
    let titleAttributedString: NSAttributedString
    let bodyAttributedString: NSAttributedString

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        title = deal?.story?.title ?? "No Title"
        body = deal?.story?.body ?? "No Body"

        let titleMarkdownParser = TSMarkdownParser.parserWithFontSize(30.0)
        titleAttributedString = titleMarkdownParser.attributedStringFromMarkdown(title)

        let bodyMarkdownParser = TSMarkdownParser.parserWithFontSize(16.0)
        bodyAttributedString = bodyMarkdownParser.attributedStringFromMarkdown(body)
    }
}
