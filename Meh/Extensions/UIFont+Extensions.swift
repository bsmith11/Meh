//
//  UIFont+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

enum MehFontStyle {
    case Regular
    case Italic
    case Bold

    var fontName: String {
        switch self {
        case .Regular:
            return UIFont.systemFontOfSize(16.0).fontName
        case .Italic:
            return UIFont.italicSystemFontOfSize(16.0).fontName
        case .Bold:
            return UIFont.boldSystemFontOfSize(16.0).fontName
        }
    }
}

extension UIFont {
    static func mehFontWithSize(size: CGFloat, style: MehFontStyle) -> UIFont {
        return UIFont(name: style.fontName, size: size)!
    }

    static func buyCellFont() -> UIFont {
        return mehFontWithSize(50.0, style: .Regular)
    }

    static func dealTitleFont() -> UIFont {
        return mehFontWithSize(20.0, style: .Regular)
    }

    static func dealFeaturesFont() -> UIFont {
        return mehFontWithSize(16.0, style: .Regular)
    }

    static func storyTitleFont() -> UIFont {
        return mehFontWithSize(30.0, style: .Regular)
    }

    static func storyBodyFont() -> UIFont {
        return mehFontWithSize(16.0, style: .Regular)
    }
}
