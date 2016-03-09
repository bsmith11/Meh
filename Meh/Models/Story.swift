//
//  Story.swift
//  Meh
//
//  Created by Bradley Smith on 3/9/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

//import Argo
//import Curry

struct Story {

    // MARK: - Properties

    let title: String
    let body: String

    init?(dictionary: Dictionary<String, String>) {
        if let title = dictionary["title"], body = dictionary["body"] {
            self.title = title
            self.body = body
        }
        else {
            return nil
        }
    }
}

//// MARK: - Decodable
//
//extension Story: Decodable {
//    static func decode(json: JSON) -> Decoded<Story> {
//        return curry(Story.init)
//            <^> json <| "title"
//            <*> json <| "body"
//    }
//}
