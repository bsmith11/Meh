//
//  FeaturesViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct FeaturesViewModel {
    let features: String
    let featuresAttributedString: NSAttributedString

    init(deal: Deal?) {
        features = deal?.features ?? "No Features"

        let markdownParser = TSMarkdownParser.parserWithFontSize(16.0)
        featuresAttributedString = markdownParser.attributedStringFromMarkdown(features)
    }
}
