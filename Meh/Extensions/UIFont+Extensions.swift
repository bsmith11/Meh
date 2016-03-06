//
//  UIFont+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

extension UIFont {
    static func mehFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: size)!
    }

    static func buyCellFont() -> UIFont {
        return mehFontWithSize(50.0)
    }

    static func dealTitleFont() -> UIFont {
        return mehFontWithSize(20.0)
    }

    static func dealFeaturesFont() -> UIFont {
        return mehFontWithSize(16.0)
    }

    static func storyTitleFont() -> UIFont {
        return mehFontWithSize(30.0)
    }

    static func storyBodyFont() -> UIFont {
        return mehFontWithSize(16.0)
    }
}
