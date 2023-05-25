//
//  UIViewController+Request.swift
//  More
//
//  Created by Luko Gjenero on 01/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func requested(for experience: Experience) {
        
        LocationService.shared.requestAlways()
        
        // success overlay
        let updatedExperience = ExperienceTrackingService.shared.updatedExperienceData(for: experience.id) ?? experience
        let post = updatedExperience.activePost()
        if post == nil || post?.creator.isMe() == true {
            presentClaimedBubble(for: experience)
        } else {
            if updatedExperience.isVirtual == true {
                presentJoinedVirtualBubble(for: experience)
            } else {
                presentJoinedBubble(for: experience)
            }
        }
    }

    func cannotRequest() {
        
        let vc = CannotRequestViewController()
        _ = vc.view
        vc.doneTap = {
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        
        let root = tabBarController ?? navigationController ?? self
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        root.view.addSubview(vc.view)
        vc.view.leadingAnchor.constraint(equalTo: root.view.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: root.view.trailingAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: root.view.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: root.view.bottomAnchor).isActive = true
        vc.viewDidAppear(false)
        
    }
    
    // MARK: - UI bubbles
    
    private func presentClaimedBubble(for experience: Experience) {
        let bubble = ClaimedBubble()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.setup(for: experience)
        presentBubble(bubble)
    }
    
    private func presentJoinedBubble(for experience: Experience) {
        let bubble = JoinedBubble()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.setup(for: experience)
        presentBubble(bubble)
    }
    
    func presentJoinedVirtualBubble(for experience: Experience) {
        let root = navigationController ?? self
        
        let bubble = VirtualJoinedBubble()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.setup(for: experience)
        bubble.enterTap = { [weak self] in
            guard let updatedExperience = ExperienceTrackingService.shared.updatedExperienceData(for: experience.id) else { return }
            guard let post = updatedExperience.activePost() else { return }
            guard let chat = post.chat else { return }
            
            ChatService.shared.getChat(chatId: chat.id, load: true, complete: { (chat) in
                if let chat = chat,
                    let nc = self?.navigationController as? MoreTabBarNestedNavigationController {
                    
                    if let chatVC = nc.topViewController as? ChatViewController,
                        chatVC.chatId == chat.id {
                        return
                    }
                    
                    let vc = ChatViewController()
                    _ = vc.view
                    vc.setup(chat: chat)
                    nc.pushViewController(vc, animated: true)
                }
            })
            root.dismissPopup()
        }
        root.present(popup: bubble)
    }
    
    private func presentBubble(_ bubble: UIView) {
        
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.alpha = 0
        
        view.addSubview(bubble)
        bubble.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        bubble.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        bubble.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        
        UIView.animate(withDuration: 0.3) { [weak bubble] in
            bubble?.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak bubble] in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    bubble?.alpha = 0
                },
                completion: { _ in
                    bubble?.removeFromSuperview()
                })
        }
    }
    
}
