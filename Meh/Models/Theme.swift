//
//  Theme.swift
//  Meh
//
//  Created by Bradley Smith on 3/9/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
//import Argo
//import Curry

struct Theme {

    // MARK: - Properties

    private(set) var accentColor = UIColor.grayColor()
    private(set) var foregroundColor = UIColor.blackColor()
    private(set) var backgroundColor = UIColor.whiteColor()

    init(dictionary: Dictionary<String, String>) {
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

//// MARK: - Decodable
//
//extension Theme: Decodable {
//    static func decode(json: JSON) -> Decoded<Theme> {
//        return curry(Theme.init)
//            <^> json <| "accentColor"
//            <*> json <| "foreground"
//            <*> json <| "backgroundColor"
//    }
//}
