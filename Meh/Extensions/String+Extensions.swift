//
//  String+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

extension String {
    func isImageURL() -> Bool {
        let prefix = hasPrefix("http")
        let suffix = hasSuffix("jpg") || hasSuffix("jpeg") || hasSuffix("png")

        return prefix && suffix
    }

    func isYoutubeURL() -> Bool {
        if let videoID = youtubeVideoID() {
            return !videoID.isEmpty
        }
        else {
            return false
        }
    }

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

    func tableMarkdownRows() -> [[String]]? {
        guard hasPrefix("|") else {
            return nil
        }

        let rawRows = componentsSeparatedByString("\n")
        let rows = rawRows.map({$0.componentsSeparatedByString("|").filter({!$0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty})})

        return rows
    }

    func stringMatchingRegexPattern(pattern: String) -> String? {
        var strings = [String]()

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let options: NSMatchingOptions = .ReportProgress
            let range = NSRange(location: 0, length: (self as NSString).length)

            regex.enumerateMatchesInString(self, options: options, range: range, usingBlock: { (result: NSTextCheckingResult?, flags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) in
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

    func stringByApplyingRegularExpression(regularExpression: NSRegularExpression, block: (NSTextCheckingResult, NSMutableString) -> Void) -> String {
        let mutableString = NSMutableString(string: self)
        let options: NSMatchingOptions = .WithoutAnchoringBounds

        var match: NSTextCheckingResult?
        var location = 0
        var range = NSRange(location: location, length: mutableString.length - location)

        match = regularExpression.firstMatchInString(String(mutableString), options: options, range: range)

        while match != nil {
            if let match = match {
                let oldLength = mutableString.length
                block(match, mutableString)
                let newLength = mutableString.length

                location = match.range.location + match.range.length + newLength - oldLength
            }

            range = NSRange(location: location, length: mutableString.length - location)
            match = regularExpression.firstMatchInString(String(mutableString), options: options, range: range)
        }

        return String(mutableString)
    }
}
