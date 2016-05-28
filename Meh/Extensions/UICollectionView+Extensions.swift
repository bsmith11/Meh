//
//  UICollectionView+Extensions.swift
//  Meh
//
//  Created by Bradley Smith on 5/26/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

extension UICollectionReusableView {
    static func reuseID() -> String {
        return NSStringFromClass(self)
    }
}

extension UICollectionView {
    func registerClass(cellClass: UICollectionViewCell.Type) {
        registerClass(cellClass, forCellWithReuseIdentifier: cellClass.reuseID())
    }

    func registerClass(supplementaryClass: UICollectionReusableView.Type, elementKind: String) {
        registerClass(supplementaryClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: supplementaryClass.reuseID())
    }

    func dequeueCellForIndexPath<T: UICollectionViewCell>(indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithReuseIdentifier(T.reuseID(), forIndexPath: indexPath) as? T else {
            preconditionFailure("Cell must of class \(T.reuseID())")
        }

        return cell
    }

    func dequeueSupplementaryViewForElementKind<T: UICollectionReusableView>(elementKind: String, indexPath: NSIndexPath) -> T {
        guard let supplementaryView = dequeueReusableSupplementaryViewOfKind(elementKind, withReuseIdentifier: T.reuseID(), forIndexPath: indexPath) as? T else {
            preconditionFailure("Supplementary view must be of class \(T.reuseID())")
        }

        return supplementaryView
    }
}
