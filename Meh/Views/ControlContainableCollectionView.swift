//
//  ControlContainableCollectionView.swift
//  Meh
//
//  Created by Bradley Smith on 3/3/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class ControlContainableCollectionView: UICollectionView {

    //MARK: - Overrides

    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if let _ = view as? UIControl {
            return true
        }
        else {
            return super.touchesShouldCancelInContentView(view)
        }
    }
}
