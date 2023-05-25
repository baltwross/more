//
//  ChatViewController+VideoCall.swift
//  More
//
//  Created by Luko Gjenero on 08/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit
import Firebase

private var conferenceView: ChatViewVideoConferenceViewController?

extension ChatViewController {

    @IBAction private func startCallButtonTouch(_ sender: Any) {
        joinCall()
    }
    
    func joinOrLeaveCall() {
        if conferenceView == nil {
            joinCall()
        } else {
            leaveCall()
        }
    }
    
    var canJoin: Bool {
        return conferenceView == nil
    }
    
    var isCallInProgress: Bool {
        return conferenceView != nil
    }
    
    var callExpanded: Bool {
        if let conferenceView = conferenceView {
            return !conferenceView.isMinimized
        }
        return false
    }
    
    private func joinCall(_ showPrep: Bool = false) {
        guard let chat = chat else { return }
        
        UIResponder.resignAnyFirstResponder()
        
        ChatService.shared.getChat(chatId: chat.id, load: false) { (chat) in
            guard let chat = chat else { return }
            if chat.videoCall == nil {
                Analytics.logEvent("CallStart", parameters: ["chatId": chat.id])
            } else {
                Analytics.logEvent("CallJoin", parameters: ["chatId": chat.id])
            }
        }
        
        let vc = navigationController ?? self
        vc.showLoading()
        VideoCallService.shared.joinCall(chat: chat, in: vc.view) { [weak self, weak vc] (success, errorMsg) in
            vc?.hideLoading()
            if success {
                self?.openCallView(showPrep)
            } else {
                self?.errorAlert(text: errorMsg ?? "Unable to start call")
            }
        }
    }
    
    func leaveCall() {
        guard conferenceView != nil else { return }
        let vc = navigationController ?? self
        vc.showLoading()
        conferenceView?.exitFromBelow { [weak self, weak vc] in
            conferenceView?.view.removeFromSuperview()
            conferenceView?.removeFromParent()
            conferenceView = nil
            VideoCallService.shared.endCall { (success, errorMsg) in
                if !success {
                    self?.showError(errorMsg ?? "Unknown error")
                }
            }
            vc?.hideLoading()
        }
        Analytics.logEvent("CallLeave", parameters: ["chatId": chat?.id ?? "--"])
    }
    
    func setupStartCallButton(chat: Chat) -> Bool {
        guard chat.videoCall == nil /* && Chat.getPost(for: chat) != nil */ else {
            return false
        }
        return true
    }
    
    private func openCallView(_ showPrep: Bool = false) {
        guard let chat = chat else { return }
        
        let vc = ChatViewVideoConferenceViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        
        add(view: vc.view)
        
        vc.setupForEnterFromBelow()
        vc.enterFromBelow()
        
        vc.backTap = { [weak self] in
            self?.minimizeCall()
        }
        
        vc.endTap = { [weak self] in
            self?.leaveCall()
        }
        
        vc.profile = { [weak self] user in
            guard let me = ProfileService.shared.profile, user.id != me.id else { return }
            let root = self?.navigationController ?? self
            root?.presentUser(user.id)
        }
        
        let root = navigationController ?? self
        vc.setSafeInsets(inset: root.view.safeAreaInsets)
        
        conferenceView = vc
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ChatService.shared.getChat(chatId: chat.id, load: true) { [weak vc] (chat) in
                if let chat = chat {
                    vc?.setup(for: chat)
                    if showPrep {
                        vc?.showPrep()
                    }
                }
            }
        }
    }
    
    private func minimizeCall() {
        guard let conferenceView = conferenceView else { return }
        conferenceView.switchToMini()
    }
    
    private func add(view: UIView, bottom: NSLayoutYAxisAnchor? = nil, dockTop: Bool = true) {
        let root = navigationController?.view ?? self.view!
        
        view.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(view)
        if dockTop {
            view.topAnchor.constraint(equalTo: root.topAnchor).isActive = true
        }
        if let bottom = bottom {
            view.bottomAnchor.constraint(equalTo: bottom).isActive = true
        } else {
            view.bottomAnchor.constraint(equalTo: root.bottomAnchor).isActive = true
        }
        view.leadingAnchor.constraint(equalTo: root.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: root.trailingAnchor).isActive = true
        view.setNeedsLayout()
    }
    
    private func showError(_ msg: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
}
