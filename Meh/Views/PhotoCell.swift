//
//  PhotoCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    // MARK: - Properties

    private var photoImageView = UIImageView(frame: CGRect.zero)

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK - Setup

    private func configureViews() {
        photoImageView.contentMode = .ScaleAspectFill
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoImageView)
    }

    private func configureLayout() {
        let photoImageViewConstraints: [NSLayoutConstraint] = [
            photoImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
            photoImageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor),
            contentView.trailingAnchor.constraintEqualToAnchor(photoImageView.trailingAnchor),
            contentView.bottomAnchor.constraintEqualToAnchor(photoImageView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(photoImageViewConstraints)
    }

    func configureWithURL(URL: NSURL?) {
        photoImageView.image = UIImage(named: "mediocre")
    }
}
