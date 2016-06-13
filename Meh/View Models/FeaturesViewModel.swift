//
//  FeaturesViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct FeaturesViewModel: ParagraphViewModelProtocol {
    let theme: Theme
    let attributedString: NSAttributedString

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        let features = deal?.features ?? "No Features"

        let markdownParser = TSMarkdownParser.parserWithFontSize(16.0, color: theme.backgroundColor)
        attributedString = markdownParser.attributedStringFromMarkdown(features)
    }
}
