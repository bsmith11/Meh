//
//  VideoCell.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import AlamofireImage

protocol VideoCellDelegate: NSObjectProtocol {
    func videoCellDidSelectVideo(cell: VideoCell)
}

class VideoCell: UICollectionViewCell {
    private let videoImageView = UIImageView(frame: .zero)
    private let videoButton = UIButton(type: .System)
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))

    private weak var delegate: VideoCellDelegate?

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

        videoImageView.af_cancelImageRequest()
    }
}

// MARK: - Public

extension VideoCell {
    func configureWithViewModel(viewModel: VideoViewModel, delegate: VideoCellDelegate?) {
        if let thumbnailURL = viewModel.videoThumbnailURL {
            videoImageView.af_setImageWithURL(thumbnailURL, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.5), runImageTransitionIfCached: false, completion: nil)
        }
        else {
            videoImageView.image = nil
        }

        videoButton.hidden = viewModel.loading
        videoButton.enabled = !viewModel.loading

        if viewModel.loading {
            spinner.startAnimating()
        }
        else {
            spinner.stopAnimating()
        }

        self.delegate = delegate
    }
}

// MARK: - Private

private extension VideoCell {
    func configureViews() {
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
        videoButton.addTarget(self, action: #selector(VideoCell.didSelectVideo), forControlEvents: .TouchUpInside)
        let image = UIImage(named: "Play Icon")?.imageWithRenderingMode(.AlwaysTemplate)
        videoButton.setImage(image, forState: .Normal)
        videoButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(videoButton)

        spinner.color = UIColor.blackColor()
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spinner)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            videoImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
            videoImageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor),
            contentView.trailingAnchor.constraintEqualToAnchor(videoImageView.trailingAnchor),
            contentView.bottomAnchor.constraintEqualToAnchor(videoImageView.bottomAnchor),

            blurView.widthAnchor.constraintEqualToConstant(80.0),
            blurView.heightAnchor.constraintEqualToConstant(80.0),
            blurView.centerXAnchor.constraintEqualToAnchor(videoImageView.centerXAnchor),
            blurView.centerYAnchor.constraintEqualToAnchor(videoImageView.centerYAnchor),

            videoButton.topAnchor.constraintEqualToAnchor(videoImageView.topAnchor),
            videoButton.leadingAnchor.constraintEqualToAnchor(videoImageView.leadingAnchor),
            videoImageView.trailingAnchor.constraintEqualToAnchor(videoButton.trailingAnchor),
            videoImageView.bottomAnchor.constraintEqualToAnchor(videoButton.bottomAnchor),

            spinner.centerXAnchor.constraintEqualToAnchor(blurView.centerXAnchor),
            spinner.centerYAnchor.constraintEqualToAnchor(blurView.centerYAnchor)
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

    @objc func didSelectVideo() {
        delegate?.videoCellDidSelectVideo(self)
    }
}

// MARK: - Static

extension VideoCell {
    static func height() -> CGFloat {
        return 200.0
    }
}
