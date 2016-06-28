//
//  ImageViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 6/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

struct ImageViewModel {
    let theme: Theme
    let imageURL: NSURL?

    init(imageURL: NSURL?, theme: Theme?) {
        self.theme = theme ?? Theme()
        self.imageURL = imageURL
    }
}
