//
//  MoreVideoView.swift
//  More
//
//  Created by Luko Gjenero on 10/01/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit
import AVKit

class MoreVideoView: UIView {
    
    private let playerLayer = AVPlayerLayer()
    
    private let video: UIView = {
        let video = UIView()
        video.translatesAutoresizingMaskIntoConstraints = false
        video.backgroundColor = .clear
        return video
    }()
    
    private let preview: UIImageView = {
        let preview = UIImageView()
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.backgroundColor = .clear
        preview.contentMode = .scaleAspectFill
        return preview
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
        addSubview(preview)
        addSubview(video)
        
        preview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        preview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        preview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        preview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        video.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        video.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        video.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        video.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    func setup(for videoUrl: URL, preview: URL? = nil) {
        
        let player = AVPlayer(url: videoUrl)
        playerLayer.player = player
        video.layer.addSublayer(playerLayer)
        
        if let preview = preview {
            self.preview.sd_progressive_setImage(with: preview)
        } else {
            self.preview.sd_cancelCurrentImageLoad_progressive()
        }
    }
    
    func setup(for video: Data, preview: URL? = nil) {
        
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFilename = "\( ProcessInfo().globallyUniqueString).mp4"
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        try? video.write(to: temporaryFileURL)

        setup(for: temporaryFileURL, preview: preview)
    }
    
    func play(loop: Bool = true) {
        playerLayer.player?.play()
        playerLayer.player?.actionAtItemEnd = .none
        
        if loop {
            NotificationCenter.default.addObserver(self, selector: #selector(loopVideo), name: .AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)
        } else {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
    @objc private func loopVideo() {
        playerLayer.player?.seek(to: .zero)
        playerLayer.player?.play()
    }
    
    func pause() {
        playerLayer.player?.pause()
    }
    
    func stop() {
        playerLayer.player?.pause()
        playerLayer.player?.seek(to: .zero)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func reset() {
        playerLayer.player?.pause()
        playerLayer.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    var isPlaying: Bool {
        if let rate = playerLayer.player?.rate, rate != 0 {
            return true
        }
        return false
    }
    
    var isSilent: Bool {
        get {
            playerLayer.player?.isMuted ?? false
        }
        set {
            playerLayer.player?.isMuted = newValue
        }
    }
    
    override var contentMode: UIView.ContentMode {
        get {
            switch playerLayer.videoGravity {
            case .resizeAspect:
                return .scaleAspectFit
            case .resizeAspectFill:
                return .scaleAspectFill
            default:
                return .scaleToFill
            }
        }
        set {
            switch newValue {
            case .scaleAspectFit:
                playerLayer.videoGravity = .resizeAspect
            case .scaleAspectFill:
                playerLayer.videoGravity = .resizeAspectFill
            default:
                playerLayer.videoGravity = .resize
            }
        }
    }
    
    func snapshot() -> UIImage? {
        playerLayer.player?.currentItem?.snapshot()
    }

    // MARK: - preview

    private func setupPreview(_ preview: URL) {
        self.preview.sd_progressive_setImage(with: preview)
    }
}
