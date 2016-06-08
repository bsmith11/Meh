//
//  PhotoCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/2/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class PhotoCell: UICollectionViewCell {
    private let photoImageView = UIImageView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureViews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        photoImageView.af_cancelImageRequest()
        photoImageView.image = nil
    }
}

// MARK: - Public

extension PhotoCell {
    func configureWithURL(URL: NSURL?, runImageTransitionIfCached: Bool) {
        if let URL = URL {
            let width = UIScreen.mainScreen().bounds.width
            let height = width - 40.0
            let size = CGSize(width: width, height: height)
            let imageFilter = AspectScaledToFitSizeFilter(size: size)

            photoImageView.af_setImageWithURL(URL, placeholderImage: nil, filter: imageFilter, imageTransition: .CrossDissolve(0.5), runImageTransitionIfCached: runImageTransitionIfCached, completion: nil)
        }
        else {
            photoImageView.image = nil
        }
    }
}

// MARK: - Private

private extension PhotoCell {
    func configureViews() {
        photoImageView.contentMode = .ScaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photoImageView)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            photoImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
            photoImageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor),
            contentView.trailingAnchor.constraintEqualToAnchor(photoImageView.trailingAnchor),
            contentView.bottomAnchor.constraintEqualToAnchor(photoImageView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}
