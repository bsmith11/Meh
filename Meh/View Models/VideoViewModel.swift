//
//  VideoViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

struct VideoViewModel {
    let theme: Theme
    let videoURL: NSURL?
    let videoThumbnailURL: NSURL?

    init(deal: Deal?) {
        theme = deal?.theme ?? Theme()

        videoURL = deal?.videoURL

        if let videoID = deal?.videoURL?.absoluteString.youtubeVideoID() {
            let string = "https://img.youtube.com/vi/" + videoID + "/hqdefault.jpg"

            videoThumbnailURL = NSURL(string: string)
        }
        else {
            videoThumbnailURL = nil
        }
    }
}
