//
//  Deal.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
//import Argo
//import Curry

struct Deal {

    // MARK: - Properties

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
        get {
            if let videoID = videoURL?.absoluteString.youtubeVideoID() {
                let string = "https://img.youtube.com/vi/" + videoID + "/hqdefault.jpg"

                return NSURL(string: string)
            }
            else {
                return nil
            }
        }
    }

    // MARK: - Lifecycle

    init?(dictionary: Dictionary<String, AnyObject>) {

        if let dealDictionary = dictionary["deal"], id = dealDictionary["id"] as? String {
            self.id = id
            title = dealDictionary["title"] as? String
            features = dealDictionary["features"] as? String
            features = features?.stringByReplacingOccurrencesOfString("\r", withString: "\n")
            features = features?.stringByReplacingOccurrencesOfString("- ", withString: "\u{2022} ")

            if let items = dealDictionary["items"] as? [Dictionary<String, AnyObject>] {
                for item in items {
                    if let priceInt = item["price"] as? Int {
                        prices.append(priceInt)
                    }
                }
            }

            specifications = dealDictionary["specifications"] as? String

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

//// MARK: - Decodable
//
//extension Deal: Decodable {
//    static func decode(json: JSON) -> Decoded<Deal> {
//        return curry(Deal.init)
//        <^> json <| "id"
//        <*> json <|? "title"
//        <*> json <|? "features"
//        <*> json <|? "specifications"
//    }
//}
