//
//  StoryViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/25/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct StoryViewModel: ParagraphViewModelProtocol {
    let theme: Theme
    let attributedString: NSAttributedString

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        let title = deal?.story?.title ?? "No Title"

        let markdownParser = TSMarkdownParser.parserWithFontSize(30.0, color: theme.backgroundColor)
        attributedString = markdownParser.attributedStringFromMarkdown(title)
    }
}
