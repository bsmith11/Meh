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

    init(videoURL: NSURL?, theme: Theme?) {
        self.theme = theme ?? Theme()
        self.videoURL = videoURL

        if let videoID = videoURL?.absoluteString.youtubeVideoID() {
            let string = "https://img.youtube.com/vi/" + videoID + "/hqdefault.jpg"

            videoThumbnailURL = NSURL(string: string)
        }
        else {
            videoThumbnailURL = nil
        }
    }
}
