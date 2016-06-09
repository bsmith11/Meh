//
//  PhotosHeaderViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import TSMarkdownParser

struct PhotosHeaderViewModel {
    private let photoURLs: [NSURL]

    let theme: Theme
    let title: String
    let titleAttributedString: NSAttributedString

    init(deal: Deal?) {
        photoURLs = deal?.photoURLs ?? []
        theme = deal?.theme ?? Theme()

        title = deal?.title ?? "No Title"

        let titleMarkdownParser = TSMarkdownParser.parserWithFontSize(20.0, alignment: .Center, color: theme.accentColor)
        titleAttributedString = titleMarkdownParser.attributedStringFromMarkdown(title)
    }
}

// MARK: - Public

extension PhotosHeaderViewModel {
    func numberOfSections() -> Int {
        return photoURLs.isEmpty ? 0 : 1
    }

    func numberOfItems() -> Int {
        return photoURLs.count
    }

    func itemAtIndexPath(indexPath: NSIndexPath) -> NSURL? {
        if indexPath.row < photoURLs.count {
            return photoURLs[indexPath.row]
        }
        else {
            return nil
        }
    }
}
