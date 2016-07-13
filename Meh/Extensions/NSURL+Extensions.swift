//
//  NSURL+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 7/12/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

extension NSURL {
    func validSchemeURL() -> NSURL? {
        let validSchemes = ["http", "https"]

        if validSchemes.contains(scheme.lowercaseString) {
            return self
        }
        else {
            let formattedURLString = "http://\(absoluteString)"

            return NSURL(string: formattedURLString)
        }
    }
}
