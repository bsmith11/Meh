//
//  VideoCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import AlamofireImage

protocol VideoCellDelegate {
    func didSelectVideo()
}

class VideoCell: UICollectionViewCell {

    // MARK: - Properties

    private let videoImageView = UIImageView(frame: CGRect.zero)
    private let videoButton = UIButton(type: .System)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))

    var delegate: VideoCellDelegate?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.whiteColor()

        configureViews()
        configureLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        videoImageView.af_cancelImageRequest()
    }

    // MARK: - Setup

    private func configureViews() {
        videoImageView.clipsToBounds = true
        videoImageView.contentMode = .ScaleAspectFill
        videoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(videoImageView)

        blurView.layer.cornerRadius = 40.0
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurView)

        videoButton.tintColor = UIColor.blackColor()
        videoButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 3.0, bottom: 0.0, right: 0.0)
        videoButton.addTarget(self, action: "didSelectVideo", forControlEvents: .TouchUpInside)
        let image = UIImage(named: "Play Icon")?.imageWithRenderingMode(.AlwaysTemplate)
        videoButton.setImage(image, forState: .Normal)
        videoButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(videoButton)
    }

    private func configureLayout() {
        let videoImageViewConstraints: [NSLayoutConstraint] = [
            videoImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
            videoImageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor),
            contentView.trailingAnchor.constraintEqualToAnchor(videoImageView.trailingAnchor),
            contentView.bottomAnchor.constraintEqualToAnchor(videoImageView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(videoImageViewConstraints)

        let blurViewConstraints: [NSLayoutConstraint] = [
            blurView.widthAnchor.constraintEqualToConstant(80.0),
            blurView.heightAnchor.constraintEqualToConstant(80.0),
            blurView.centerXAnchor.constraintEqualToAnchor(videoImageView.centerXAnchor),
            blurView.centerYAnchor.constraintEqualToAnchor(videoImageView.centerYAnchor)
        ]

        NSLayoutConstraint.activateConstraints(blurViewConstraints)

        let videoButtonConstraints: [NSLayoutConstraint] = [
            videoButton.topAnchor.constraintEqualToAnchor(videoImageView.topAnchor),
            videoButton.leadingAnchor.constraintEqualToAnchor(videoImageView.leadingAnchor),
            videoImageView.trailingAnchor.constraintEqualToAnchor(videoButton.trailingAnchor),
            videoImageView.bottomAnchor.constraintEqualToAnchor(videoButton.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(videoButtonConstraints)
    }

    func configureWithDeal(deal: Deal?) {
        if let URL = deal?.videoURLThumbnail {
            videoImageView.af_setImageWithURL(URL, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.5), runImageTransitionIfCached: false, completion: nil)
        }
        else {
            videoImageView.image = nil
        }
    }

    // MARK: - Actions

    func didSelectVideo() {
        delegate?.didSelectVideo()
    }

    static func height() -> CGFloat {
        return 200.0
    }
}
