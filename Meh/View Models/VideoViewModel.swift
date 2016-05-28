//
//  VideoViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

struct VideoViewModel {
    let videoThumbnailURL: NSURL?

    init(deal: Deal?) {
        if let videoID = deal?.videoURL?.absoluteString.youtubeVideoID() {
            let string = "https://img.youtube.com/vi/" + videoID + "/hqdefault.jpg"

            videoThumbnailURL = NSURL(string: string)
        }
        else {
            videoThumbnailURL = nil
        }
    }
}
