//
//  ExploreViewController+NavigationBar.swift
//  More
//
//  Created by Luko Gjenero on 29/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import SwiftMessages

extension ExploreViewController {
    

    func setupNavigationBar() {
        // left button - profile
        trackProfile()
        setLeftNavigationButton()

        
        // right button - inbox
        trackRequests()
        highlightRequestsTabIfNeeded()
        
        // Set navigation bar background color
           // navigationController?.navigationBar.barTintColor = UIColor.red
        navigationController?.navigationBar.backgroundColor = UIColor.whiteTwo
        
        

    }
    
    // MARK: - profile button & tracking profile changes
    
    @objc private func setLeftNavigationButton() {
        let profile = AvatarImage(frame: .zero)
        profile.isUserInteractionEnabled = false
        profile.translatesAutoresizingMaskIntoConstraints = false
        profile.heightAnchor.constraint(equalToConstant: 30).isActive = true
        profile.widthAnchor.constraint(equalToConstant: 30).isActive = true
        if let model = ProfileService.shared.userModel() {
            profile.sd_progressive_setImage(with: URL(string: model.avatarUrl))
        }
        setLeftContent(profile)
        leftTap = { [weak self] in
            self?.presentProfile()
        }
    }
    
    private func trackProfile() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setLeftNavigationButton),
            name: ProfileService.Notifications.ProfilePhotos,
            object: nil)
    }
    
    private func presentProfile() {
        let vc = OwnProfileViewController()
        _ = vc.view
        vc.backTap = { [weak self] in
            // self?.navigationController?.popViewController(animated: true)
            self?.navigationController?.popViewController(animated: true, subType: .fromRight)
        }
        // navigationController?.pushViewController(vc, animated: true)
        navigationController?.pushViewController(vc, animated: true, subType: .fromLeft)
    }
    
    // MARK: - right button & tracking requests (chats)
    
    @objc private func setRightNavigationButton(_ unread: Int) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        let icon = UIImageView(image: UIImage(named: "requests-inbox"))
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 7, y: 10, width: 26, height: 20)
        view.addSubview(icon)
        
        if unread > 0 {
            let badge = UILabel(frame: CGRect(x: 19, y: -4, width: 25, height: 25))
            badge.backgroundColor = .brightSkyBlue
            badge.font = UIFont(name: "DIN-Bold", size: 15)
            badge.textColor = .white
            badge.textAlignment = .center
            badge.layer.cornerRadius = 12.5
            badge.layer.masksToBounds = true
            if unread > 9 {
                badge.text = "9+"
            } else {
                badge.text = "\(unread)"
            }
            view.addSubview(badge)
        }
        
        setRightContent(view)
        rightTap = { [weak self] in
            self?.presentRequests()
        }
    }
    
    private func trackRequests() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadChats(_:)), name: ChatService.Notifications.ChatsLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newChatMessage(_:)), name: ChatService.Notifications.ChatMessage, object: nil)
        highlightRequestsTabIfNeeded()
    }
    
    @objc private func reloadChats(_ notice: Notification) {
        highlightRequestsTabIfNeeded()
    }
    
    @objc private func newChatMessage(_ notice: Notification) {
        highlightRequestsTabIfNeeded()
        DispatchQueue.main.async { [weak self] in
            self?.internalNewChatMessage(notice)
        }
    }
    
    private func internalNewChatMessage(_ notice: Notification) {
        guard !(presentedViewController is EnRouteV2ViewController) else { return }
        guard let chatId = notice.userInfo?["chatId"] as? String else { return }
        
        // do not show for opened chat
        if let nc = navigationController as? MoreTabBarNestedNavigationController,
            let chatVC = nc.topViewController as? ChatViewController,
            chatVC.chatId == chatId && !chatVC.callExpanded {
            return
        }
        
        if let message = notice.userInfo?["message"] as? Message,
            let type = notice.userInfo?["update"] as? String , type == "new",
            !message.isMine(),
            !message.haveRead() && !message.wasDelivered(),
            (message.type == .text || message.type == .photo || message.type == .video ||
                message.type == .startCall || message.type == .joined || message.type == .created) {
            
            SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: .normal)
            let view: AlertMessageView = try! SwiftMessages.viewFromNib()
            view.configureTheme(backgroundColor: UIColor(red: 244, green: 244, blue: 244), foregroundColor: .clear)
            view.button?.backgroundColor = .clear
            
            let experience = ExperienceTrackingService.shared.getActiveExperiences().first(where: { experience in
                if experience.myPost()?.chat?.id == chatId {
                    return true
                }
                if let request = experience.myRequest(), experience.post(for: request.id)?.chat?.id == chatId {
                    return true
                }
                return false
            })
            
            if let post = experience?.myPost() {
                view.content.setupForMessgae(message, in: post)
            } else if let request = experience?.myRequest(), let post = experience?.post(for: request.id) {
                view.content.setupForMessgae(message, in: post)
            } else {
                view.content.setupForMessgae(message)
            }
            
            view.tapHandler = { [weak self] _ in
                self?.dismiss(animated: false, completion: nil)
                if let chat = ChatService.shared.getChats().first(where: { $0.id == chatId }),
                    let nc = self?.navigationController as? MoreTabBarNestedNavigationController {
                    
                    if let chatVC = nc.topViewController as? ChatViewController,
                        chatVC.chatId == chatId {
                        return
                    }
                    
                    let vc = ChatViewController()
                    _ = vc.view
                    vc.setup(chat: chat)
                    nc.pushViewController(vc, animated: true)
                }
            }
            
            SwiftMessages.show(view: view)
        }
        highlightRequestsTabIfNeeded()
    }
    
    private func highlightRequestsTabIfNeeded() {
        let unread = ChatService.shared.getChats().reduce(0) { (previous, chat) -> Int in
            let unread = chat.messages?.filter { !$0.isMine() && $0.readAt == nil }.count ?? 0
            return previous + unread
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.setRightNavigationButton(unread)
        }
    }
    
    private func presentRequests() {
        let vc = RequestsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
