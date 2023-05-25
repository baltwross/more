//
//  ChatViewVideoView.swift
//  More
//
//  Created by Luko Gjenero on 08/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit
import TwilioVideo

@IBDesignable
class ChatViewVideoView: LoadableView {

    @IBOutlet private weak var content: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var avatarView: TimeAvatarView!
    @IBOutlet private weak var videoView: UIView!
    @IBOutlet private weak var audio: UIButton!
    
    var tap: (()->())?
    var doubleTap: (()->())?
    var audioTap: (()->())?
    
    private (set) var user: ShortUser?
    
    private var video: VideoView? {
        return videoView.subviews.first(where: { $0 is VideoView }) as? VideoView
    }
    
    override func setupNib() {
        super.setupNib()
        
        content.layer.masksToBounds = true
        
        avatarView.progress = 0
        avatarView.progressBackgroundColor = .clear
        avatarView.outlineColor = UIColor(red: 191, green: 195, blue: 202).withAlphaComponent(0.75)
        avatarView.ringSize = 1
        avatarView.imagePadding = 3
        
        videoView.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragContent(sender:)))
        addGestureRecognizer(pan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged), name: VideoCallService.Notifications.AudioSettingsChanged, object: nil)
    }
    
    func setup(for user: ShortUser) {
        self.user = user
        nameLabel.text = user.name
        avatarView.imageUrl = user.avatar
        videoView.isHidden = false
        nameLabel.isHidden = false
        avatarView.isHidden = false
    }
    
    func setupVideo(for participant: RemoteParticipant?) {
        setupVideo(for: participant?.remoteVideoTracks.first?.remoteTrack)
        audio.isHidden = true
        
    }
    
    func setupVideoForMe(showAudio: Bool = false) {
        let shouldMirror = VideoCallService.shared.videoTrack?.shouldMirror ?? false
        setupVideo(for: VideoCallService.shared.videoTrack, mirror: shouldMirror)
        audio.isHidden = !showAudio
        updateAudio()
    }
    
    func resetVideo(for participant: RemoteParticipant?) {
        resetVideo(for: participant?.remoteVideoTracks.first?.remoteTrack)
    }
    
    func resetVideoForMe() {
        resetVideo(for: VideoCallService.shared.videoTrack)
    }
    
    func toggleVideo() {
        videoView.isHidden = !videoView.isHidden
    }
    
    var userAplha: CGFloat {
        get {
            return nameLabel.alpha
        }
        set {
            nameLabel.alpha = newValue
            avatarView.alpha = newValue
        }
    }
    
    var audioAplha: CGFloat {
        get {
            return audio.alpha
        }
        set {
            audio.alpha = newValue
        }
    }
    
    var videoCornerRadius: CGFloat {
        get {
            return content.layer.cornerRadius
        }
        set {
            content.layer.cornerRadius = newValue
        }
    }
    
    var isPanEnabled: Bool = false
    
    func hideUser(_ hide: Bool) {
        nameLabel.isHidden = hide
        avatarView.isHidden = hide
    }
    
    private func setupVideo(for videoTrack: VideoTrack?, mirror: Bool = false) {
        
        videoView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let videoTrack = videoTrack else { return }
        
        let video = VideoView()
        video.translatesAutoresizingMaskIntoConstraints = false
        video.shouldMirror = mirror
        video.contentMode = .scaleAspectFill
        
        videoView.addSubview(video)
        video.topAnchor.constraint(equalTo: videoView.topAnchor).isActive = true
        video.bottomAnchor.constraint(equalTo: videoView.bottomAnchor).isActive = true
        video.leadingAnchor.constraint(equalTo: videoView.leadingAnchor).isActive = true
        video.trailingAnchor.constraint(equalTo: videoView.trailingAnchor).isActive = true
        
        videoTrack.addRenderer(video)
    }
    
    func updateMirror(_ shouldMirror: Bool) {
        video?.shouldMirror = shouldMirror
    }
    
    func updateVideo(_ videoEnabled: Bool) {
        video?.isHidden = !videoEnabled
    }
    
    private func resetVideo(for videoTrack: VideoTrack?) {
        if let video = video {
            videoTrack?.removeRenderer(video)
        }
    }
    
    @objc private func settingsChanged(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.updateAudio()
        }
    }
    
    private func updateAudio() {
        let audioEnabled = VideoCallService.shared.audioEnabled
        audio.tintColor = audioEnabled ? .whiteThree : .fireEngineRed
    }
    
    @objc private func tapAction() {
        tap?()
    }
    
    @objc private func doubleTapAction() {
        doubleTap?()
    }
    
    @IBAction private func audioTouch() {
        audioTap?()
    }
    
    // MARK: - drag
    
    private var dragStart: CGPoint = .zero
    private var isDown: Bool = false
    
    @objc private func dragContent(sender: UIPanGestureRecognizer) {
        
        guard layer.animationKeys() == nil else { return }
        guard let parent = superview else { return }
        
        let point = sender.location(in: parent)
        let offset = dragStart.y - point.y
        switch sender.state {
        case .began:
            dragStart = point
        case .changed:
            move(to: -offset)
        case .cancelled, .ended, .failed:
            settle(to: -offset)
        default: ()
        }
    }
    
    private func move(to offset: CGFloat) {
        var clampedOffset = max(0, min(offset, 120))
        if isDown {
            clampedOffset = 120 - max(0, min(-offset, 120))
        }
        layer.transform = CATransform3DMakeTranslation(0, clampedOffset, 0)
    }
    
    private func settle(to offset: CGFloat) {
        let clampedOffset = max(0, min(offset, 120))
        let end: CGFloat = clampedOffset > 60 ? 120 : 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layer.transform = CATransform3DMakeTranslation(0, end, 0)
        }
        isDown = end == 120
    }
}
