//
//  HeaderCollectionViewLayoutAttributes.swift
//  Meh
//
//  Created by Bradley Smith on 3/6/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class HeaderCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    // MARK: - Properties

    var isPinned = false

    // MARK: - Lifecycle

    override func copyWithZone(zone: NSZone) -> AnyObject {
        if let copy = super.copyWithZone(zone) as? HeaderCollectionViewLayoutAttributes {
            copy.isPinned = isPinned

            return copy
        }
        else {
            return super.copyWithZone(zone)
        }
    }
}
