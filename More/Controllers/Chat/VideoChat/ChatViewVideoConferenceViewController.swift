//
//  ChatViewVideoConferenceViewController.swift
//  More
//
//  Created by Luko Gjenero on 08/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

private var counter = 1

class ChatViewVideoConferenceViewController: UIViewController {

    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var conference: ChatViewVideoConferenceView!
    @IBOutlet private weak var controls: ChatViewVideoControlsView!
    @IBOutlet private weak var topFade: VerticalGradientView!
    @IBOutlet private weak var bottomFade: VerticalGradientView!
    @IBOutlet private weak var userTag: ChatViewVideoUserTag!
    
    @IBOutlet private weak var topPadding: NSLayoutConstraint!
    @IBOutlet private weak var bottomPadding: NSLayoutConstraint!
    
    private(set) var chat: Chat?
    
    var backTap: (()->())?
    var endTap: (()->())?
    var restore: (()->())?
    var profile: ((_ user: ShortUser)->())?
    
    var isMinimized: Bool {
        return conference.isMinimized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        topFade.colors = [
            UIColor.black.withAlphaComponent(0.35).cgColor,
            UIColor.clear.cgColor,
        ]
        
        bottomFade.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.35).cgColor,
        ]
        
        back.layer.transform = CATransform3DMakeRotation(-CGFloat.pi * 0.5, 0, 0, 1)
        
        userTag.isHidden = true
        
        userTag.tap = { [weak self] in
            if let user = self?.userTag.user {
                self?.profile?(user)
            }
        }
     
        // MOCK for testing
//        var members: [ShortUser] = []
//        for i in 0..<counter {
//            let user = ShortUser(id: "\(i+1)", name: "Profile \(i)", avatar: "https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500")
//            members.append(user)
//        }
//
//        let videoCall = VideoCall(id: "", sessionId: "", createdAt: Date(), members: members)
//        let chat = Chat(id: "", createdAt: Date(), members: [], type: .group, messages: nil, typing: [], archived: nil, videoCall: videoCall)
//
//        conference.setup(for: chat)
//        counter += 1
        
        conference.expanded = { [weak self] user in
            self?.userTag.setup(for: user)
            self?.userTag.alpha = 0
            self?.userTag.isHidden = false
            UIView.animate(
                withDuration: 0.2,
                delay: 0.2,
                options: [],
                animations: {
                    self?.userTag.alpha = 1
                    self?.back.setImage(UIImage(named: "close"), for: .normal)
                },
                completion: { _ in
                    // nop
                })
        }
        
        conference.collapsed = { [weak self] in
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self?.userTag.alpha = 0
                    self?.back.setImage(UIImage(named: "back_white"), for: .normal)
                },
                completion: { _ in
                    self?.userTag.isHidden = false
                })
        }
        
        conference.audio = {
            VideoCallService.shared.audioEnabled = !VideoCallService.shared.audioEnabled
        }
        
        conference.restore = { [weak self] in
            self?.switchBackFromMini()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged), name: VideoCallService.Notifications.VideoSettingsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged), name: VideoCallService.Notifications.AudioSettingsChanged, object: nil)
        
        controls.micTap = {
            VideoCallService.shared.audioEnabled = !VideoCallService.shared.audioEnabled
        }
        
        controls.cameraTap = {
            VideoCallService.shared.videoEnabled = !VideoCallService.shared.videoEnabled
        }
        
        controls.flipTap = {
            VideoCallService.shared.flipCamera()
        }
        
        controls.callTap = { [weak self] in
            self?.endTap?()
        }
    }
    
    func setup(for chat: Chat) {
        self.chat = chat
        conference.setup(for: chat)
        settingsChanged()
    }
    
    func setSafeInsets(inset: UIEdgeInsets) {
        topPadding.constant = inset.top
        bottomPadding.constant = 20 + inset.bottom
    }
    
    func switchToMini() {
        back.isHidden = true
        controls.isHidden = true
        userTag.isHidden = true
        topFade.isHidden = true
        bottomFade.isHidden = true
        view.backgroundColor = .clear
        
        conference.switchToMini()
    }
    
    func switchBackFromMini() {
        back.isHidden = false
        controls.isHidden = false
        userTag.isHidden = !conference.isExpanded
        topFade.isHidden = false
        bottomFade.isHidden = false
        UIResponder.resignAnyFirstResponder()
        
        conference.switchBackFromMini()
    }
    
    func showPrep() {
        conference.showPrep()
    }

    @IBAction private func backTouch(_ sender: Any) {
        if conference.isExpanded {
            conference.collapse()
        } else {
            backTap?()
        }
    }
    
    // MARK: - data changes
    
    @objc private func settingsChanged() {
        controls.micEnabled = VideoCallService.shared.audioEnabled
        controls.cameraEnabled = VideoCallService.shared.videoEnabled
    }
}

// MARK: - touch management
class ChatViewVideoConferenceViewControllerView : UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews {
            let insideSubview = !view.isHidden &&
                view.alpha == 1 &&
                view.point(inside: convert(point, to: view), with: event)
            if insideSubview {
                return true
            }
        }
        return false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit == self {
            return nil
        }
        return hit
    }
}
