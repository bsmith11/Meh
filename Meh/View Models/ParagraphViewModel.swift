//
//  ParagraphViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 6/12/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

protocol ParagraphViewModelProtocol {
    var theme: Theme { get }
    var attributedString: NSAttributedString { get }
}

struct ParagraphViewModel: ParagraphViewModelProtocol {
    let theme: Theme
    let attributedString: NSAttributedString

    init(paragraph: String?, theme: Theme?) {
        self.theme = theme ?? Theme()

        let markdownParser = TSMarkdownParser.parserWithFontSize(16.0, color: self.theme.backgroundColor)
        let string = paragraph ?? "No Title"
        attributedString = markdownParser.attributedStringFromMarkdown(string)
    }
}
