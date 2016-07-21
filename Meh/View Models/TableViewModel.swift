//
//  TableViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 7/14/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct TableViewModel {
    let theme: Theme
    let rows: [[NSAttributedString]]

    init(rows: [[String]], theme: Theme?) {
        self.theme = theme ?? Theme()

        let markdownParser = TSMarkdownParser.parserWithFontSize(16.0, color: self.theme.backgroundColor)

        self.rows = rows.map { (row: [String]) -> [NSAttributedString] in
            row.map({markdownParser.attributedStringFromMarkdown($0)})
        }
    }
}
