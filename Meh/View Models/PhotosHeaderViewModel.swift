//
//  PhotosHeaderViewModel.swift
//  Meh
//
//  Created by Bradley Smith on 5/27/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import Foundation

struct PhotosHeaderViewModel {
    private let photoURLs: [NSURL]

    let theme: Theme

    init(deal: Deal?) {
        photoURLs = deal?.photoURLs ?? []
        theme = deal?.theme ?? Theme()
    }
}

// MARK: - Public

extension PhotosHeaderViewModel {
    func numberOfSections() -> Int {
        return photoURLs.isEmpty ? 0 : 1
    }

    func numberOfItems() -> Int {
        return photoURLs.count
    }

    func itemAtIndexPath(indexPath: NSIndexPath) -> NSURL? {
        if indexPath.row < photoURLs.count {
            return photoURLs[indexPath.row]
        }
        else {
            return nil
        }
    }
}
