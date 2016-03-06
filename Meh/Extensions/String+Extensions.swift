//
//  String+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

extension String {
    func youtubeVideoID() -> String? {
        var pattern = "(?<=watch\\?v=|/videos/|embed\\/)[^#\\&\\?]*"

        if let videoID = stringMatchingRegexPattern(pattern) {
            return videoID
        }
        else {
            pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"

            return stringMatchingRegexPattern(pattern)
        }
    }

    func stringMatchingRegexPattern(pattern: String) -> String? {
        var strings = [String]()

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let options: NSMatchingOptions = .ReportProgress
            let range = NSRange.init(location: 0, length: (self as NSString).length)

            regex.enumerateMatchesInString(self, options: options, range: range, usingBlock: { (result: NSTextCheckingResult?, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                if let result = result {
                    let match = (self as NSString).substringWithRange(result.range)
                    strings.append(match)
                }
            })

            return strings.first
        }
        catch _ {
            print("Failed to create regular expression with pattern: \(pattern)")

            return nil
        }
    }
}
