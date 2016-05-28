//
//  StoryViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/25/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import SwiftyMarkdown

struct StoryViewModel {
    let title: String
    let body: String
    let titleAttributedString: NSAttributedString
    let bodyAttributedString: NSAttributedString

    init(story: Story?) {
        title = story?.title ?? "No Title"
        body = story?.body.stringByReplacingOccurrencesOfString("\r\n\r\n", withString: "\n\n") ?? "No Body"

        let titleMarkdown = SwiftyMarkdown.markdownWithString(title, fontSize: 30.0)
        titleAttributedString = titleMarkdown.attributedString().attributedStringByApplyingLineBreakMode(.ByWordWrapping)

        let bodyMarkdown = SwiftyMarkdown.markdownWithString(body, fontSize: 16.0)
        bodyAttributedString = bodyMarkdown.attributedString().attributedStringByApplyingLineBreakMode(.ByWordWrapping)
    }
}
