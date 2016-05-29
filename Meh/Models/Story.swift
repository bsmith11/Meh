//
//  Story.swift
//  Meh
//
//  Created by Bradley Smith on 3/9/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

struct Story {
    let title: String
    let body: String

    init?(dictionary: [String: String]) {
        if let title = dictionary["title"], body = dictionary["body"] {
            self.title = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.body = body.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        else {
            return nil
        }
    }
}
