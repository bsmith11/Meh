//
//  VideoViewController.swift
//  Meh
//
//  Created by Bradley Smith on 3/4/16.
//  Copyright © 2016 Brad Smith. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoViewController: UIViewController {

    // MARK: - Properties

    private var URL: NSURL?
    private var playerView = YTPlayerView(frame: CGRect.zero)

    private let playerVariables = [
        "rel": 0,
        "showinfo": 0
    ]

    // MARK: - Lifecycle

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    init(URL: NSURL?) {
        self.URL = URL

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()

        configureViews()
        configureLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let videoID = URL?.absoluteString.youtubeVideoID() {
            playerView.loadWithVideoId(videoID, playerVars: playerVariables)
        }
    }

    // MARK: - Setup

    private func configureViews() {
        playerView.delegate = self
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
    }

    private func configureLayout() {
        let playerViewConstraints: [NSLayoutConstraint] = [
            playerView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            playerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            view.trailingAnchor.constraintEqualToAnchor(playerView.trailingAnchor),
            view.bottomAnchor.constraintEqualToAnchor(playerView.bottomAnchor)
        ]

        NSLayoutConstraint.activateConstraints(playerViewConstraints)
    }
}

extension VideoViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        print("Ready...")
        playerView.playVideo()
    }

    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        print("State: \(state.rawValue)")
    }

    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {

    }
}
