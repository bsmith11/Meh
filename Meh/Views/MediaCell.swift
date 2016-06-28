//
//  MediaCell.swift
//  Meh
//
//  Created by Bradley Smith on 6/17/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import AlamofireImage

private enum MediaCellState {
    case Image
    case Video
}

class MediaCell: UICollectionViewCell {
    private let mediaImageView = UIImageView(frame: .zero)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    private let playImageView = UIImageView(frame: .zero)

    private var horizontalConstraints = [NSLayoutConstraint]()

    var imageViewFrame: CGRect {
        return mediaImageView.frame
    }

    var imageViewSuperview: UIView? {
        return mediaImageView.superview
    }

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

        mediaImageView.af_cancelImageRequest()
        mediaImageView.image = nil
    }
}

// MARK: - Public

extension MediaCell {
    func configureWithViewModel(viewModel: VideoViewModel) {
        backgroundColor = viewModel.theme.accentColor

        if let thumbnailURL = viewModel.videoThumbnailURL {
            mediaImageView.af_setImageWithURL(thumbnailURL, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.5), runImageTransitionIfCached: false, completion: nil)
        }
        else {
            mediaImageView.image = nil
        }

        configureWithState(.Video)
    }

    func configureWithViewModel(viewModel: ImageViewModel) {
        backgroundColor = viewModel.theme.accentColor

        if let imageURL = viewModel.imageURL {
            mediaImageView.af_setImageWithURL(imageURL, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.5), runImageTransitionIfCached: false, completion: nil)
        }
        else {
            mediaImageView.image = nil
        }

        configureWithState(.Image)
    }

    func showSubviews(shown: Bool, animated: Bool) {
        let alpha: CGFloat = shown ? 1.0 : 0.0

        if animated {
            let animations = {
                UIView.performWithoutAnimation({
                    self.mediaImageView.alpha = alpha
                })

                self.blurView.alpha = alpha
            }
            UIView.animateWithDuration(0.5, animations: animations)
        }
        else {
            blurView.alpha = alpha
            mediaImageView.alpha = alpha
        }
    }
}

// MARK: - Private

private extension MediaCell {
    func configureViews() {
        mediaImageView.clipsToBounds = true
        mediaImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mediaImageView)

        blurView.layer.cornerRadius = 40.0
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurView)

        playImageView.tintColor = UIColor.blackColor()
        playImageView.image = UIImage(named: "Play Icon")?.imageWithRenderingMode(.AlwaysTemplate)
        playImageView.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(playImageView)
    }

    func configureLayout() {
        let constraints: [NSLayoutConstraint] = [
            mediaImageView.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            mediaImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
            contentView.bottomAnchor.constraintEqualToAnchor(mediaImageView.bottomAnchor, constant: 20.0),

            blurView.widthAnchor.constraintEqualToConstant(80.0),
            blurView.heightAnchor.constraintEqualToConstant(80.0),
            blurView.centerXAnchor.constraintEqualToAnchor(mediaImageView.centerXAnchor),
            blurView.centerYAnchor.constraintEqualToAnchor(mediaImageView.centerYAnchor),

            playImageView.centerXAnchor.constraintEqualToAnchor(blurView.centerXAnchor),
            playImageView.centerYAnchor.constraintEqualToAnchor(blurView.centerYAnchor)
        ]

        horizontalConstraints = [
            mediaImageView.leadingAnchor.constraintEqualToAnchor(contentView.leadingAnchor),
            contentView.trailingAnchor.constraintEqualToAnchor(mediaImageView.trailingAnchor),
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

    func configureWithState(state: MediaCellState) {
        switch state {
        case .Image:
            blurView.hidden = true
            mediaImageView.contentMode = .ScaleAspectFit
            NSLayoutConstraint.deactivateConstraints(horizontalConstraints)
        case .Video:
            blurView.hidden = false
            mediaImageView.contentMode = .ScaleAspectFill
            NSLayoutConstraint.activateConstraints(horizontalConstraints)
        }
    }
}

// MARK: - Static

extension MediaCell {
    static func height() -> CGFloat {
        return 200.0 + 20.0
    }
}
