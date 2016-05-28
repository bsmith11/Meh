//
//  Theme.swift
//  Meh
//
//  Created by Bradley Smith on 3/9/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

struct Theme {
    private(set) var accentColor = UIColor.grayColor()
    private(set) var foregroundColor = UIColor.blackColor()
    private(set) var backgroundColor = UIColor.whiteColor()

    init(dictionary: [String: String]) {
        if let accent = dictionary["accentColor"] {
            accentColor = UIColor(hexString: accent)
        }

        if let foreground = dictionary["foreground"] {
            if foreground == "dark" {
                foregroundColor = UIColor.blackColor()
            }
            else {
                foregroundColor = UIColor.whiteColor()
            }
        }

        if let background = dictionary["backgroundColor"] {
            backgroundColor = UIColor(hexString: background)
        }
    }

    init() {

    }
}
