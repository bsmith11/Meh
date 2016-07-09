//
//  Deal.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

struct Deal {
    private(set) var id: String
    private(set) var title: String?
    private(set) var features: String?
    private(set) var prices = [Int]()
    private(set) var soldOutDate: NSDate?
    private(set) var specifications: String?
    private(set) var story: Story?
    private(set) var theme: Theme
    private(set) var URL: NSURL?
    private(set) var videoURL: NSURL?
    private(set) var photoURLs = [NSURL]()

    var videoURLThumbnail: NSURL? {
        if let videoID = videoURL?.absoluteString.youtubeVideoID() {
            let string = "https://img.youtube.com/vi/" + videoID + "/hqdefault.jpg"

            return NSURL(string: string)
        }
        else {
            return nil
        }
    }

    init?(dictionary: [String: AnyObject]) {
        if let dealDictionary = dictionary["deal"], id = dealDictionary["id"] as? String {
            self.id = id
            title = dealDictionary["title"] as? String

            if let featuresString = dealDictionary["features"] as? NSString {
                features = featuresString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                var featuresCompoundString = ""

                let range = NSRange(location: 0, length: featuresString.length)
                let block = { (substring: String?, substringRange: NSRange, enclosingRange: NSRange, stop: UnsafeMutablePointer<ObjCBool>) in
                    if var substring = substring where !substring.isEmpty {
                        substring = substring.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        substring.appendContentsOf("\n\n")

                        featuresCompoundString.appendContentsOf(substring)
                    }
                }

                (featuresString as NSString).enumerateSubstringsInRange(range, options: .ByParagraphs, usingBlock: block)

                features = featuresCompoundString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }

            if let items = dealDictionary["items"] as? [Dictionary<String, AnyObject>] {
                for item in items {
                    if let priceInt = item["price"] as? Int {
                        prices.append(priceInt)
                    }
                }
            }

            if let dateString = dealDictionary["soldOutAt"] as? String {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
                soldOutDate = dateFormatter.dateFromString(dateString)
            }

            specifications = dealDictionary["specifications"] as? String

            do {
                let regex = try NSRegularExpression(pattern: "^(.*)\r\n====", options: .AnchorsMatchLines)
                let block = { (result: NSTextCheckingResult, mutableString: NSMutableString) in
                    let removalRange = (mutableString as NSString).rangeOfString("\r\n====", options: .LiteralSearch, range: result.range)
                    mutableString.replaceCharactersInRange(removalRange, withString: "\r\n\r\n")
                    mutableString.insertString("#", atIndex: result.range.location)
                }

                specifications = specifications?.stringByApplyingRegularExpression(regex, block: block)
            }
            catch {
                print("Failed to initialize regular expression")
            }

            if let storyDictionary = dealDictionary["story"] as? Dictionary<String, String> {
                story = Story(dictionary: storyDictionary)
            }

            if let themeDictionary = dealDictionary["theme"] as? Dictionary<String, String> {
                theme = Theme(dictionary: themeDictionary)
            }
            else {
                theme = Theme()
            }

            if let urlString = dealDictionary["url"] as? String {
                URL = NSURL(string: urlString)
            }

            if let videoDictionary = dictionary["video"] as? Dictionary<String, AnyObject> {
                if let urlString = videoDictionary["url"] as? String {
                    videoURL = NSURL(string: urlString)
                }
            }

            if let photos = dealDictionary["photos"] as? [String] {
                for photo in photos {
                    if let photoURL = NSURL(string: photo) {
                        photoURLs.append(photoURL)
                    }
                }
            }
        }
        else {
            return nil
        }
    }
}
