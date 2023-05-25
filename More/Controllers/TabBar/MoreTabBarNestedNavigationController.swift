//
//  MoreTabBarNestedNavigationController.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class MoreTabBarNestedNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = true
        
        setupNavBar()
        
        enableSwipeToPop()
        
        trackTimes()
        
        trackPNs()
    }
    
    private var isFirst = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        processPN()
    }
    
    // MARK: - navigation bar
    
    private func setupNavBar() {
        navigationBar.barTintColor = .whiteTwo
        navigationBar.shadowImage = UIImage.onePixelImage(color: .iceBlue)
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.charcoalGrey,
            .font: UIFont(name: "Gotham-Medium", size: 14)!,
            .kern: 0.86
        ]
    }
    
    func hideNavigation(hide: Bool, animated: Bool) {
        setNavigationBarHidden(hide, animated: animated)
    }
    
    // MARK: - splash loading
    
    private var splash: SplashView? {
        return view.viewWithTag(12345678) as? SplashView
    }
    
    func waitWithSplash() {
        
        let image = SplashView()
        image.tag = 12345678
        image.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(image)
        image.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        image.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        image.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) { [weak self] in
            self?.removeSplash()
        }
    }
    
    private func removeSplash() {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.splash?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.splash?.removeFromSuperview()
        })
    }
    
    // MARK: - tracking times
    
    private func trackTimes() {
        NotificationCenter.default.addObserver(self, selector: #selector(newTime(_:)), name: TimesService.Notifications.TimeLoaded, object: nil)
        if let time = TimesService.shared.getActiveTime() {
            presentTime(time)
        }
    }
    
    @objc private func newTime(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let time = notice.userInfo?["time"] as? ExperienceTime {
                if !time.isFinished() {
                    self?.presentTime(time)
                }
            }
        }
    }
    
    private func presentTime(_ time: ExperienceTime) {
        guard !(presentedViewController is EnRouteV2ViewController) else { return }
        
        if presentedViewController != nil {
            dismiss(animated: true) { [weak self] in
                self?.internalPresentTime(time)
            }
        } else {
            internalPresentTime(time)
        }
    }
    
    private func internalPresentTime(_ time: ExperienceTime) {
        let vc = EnRouteV2ViewController()
        _ = vc.view
        vc.setup(for: time)
        present(vc, animated: true, completion: nil)
    }
    
    func presentReview(for time: Time) {
        guard !time.haveReviewed() else { return }
        
        let vc = ReviewViewController()
        _ = vc.view
        vc.setup(for: time)
        vc.closeTap = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - tracking PNs
    
    private func trackPNs() {
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPNInForeground), name: PushNotificationService.Notifications.NotificationReceived, object: nil)
    }
    
    @objc private func toForeground() {
        processPN()
    }
    
    @objc private func toBackground() {
        // nothing
    }
    
    // MARK: - Push Notifications
    
    private func processPN() {
        guard ProfileService.shared.profile?.getId() != nil else { return }
        if let info = PushNotificationService.shared.popLastMessage(),
            let type = info["type"] as? String {
            
            switch type {
            case "newPost":
                processNewPostPN(info, check: true)
            case "newRequest":
                processNewRequestPN(info)
            case "newMessage":
                processNewMessagePN(info)
            case "deeplink":
                processDeeplinkPN(info)
            case "newLike":
                processNewLikePN(info)
            default:
                ()
            }
        }
    }
    
    @objc private func processPNInForeground() {
        guard ProfileService.shared.profile?.getId() != nil else { return }
        if let info = PushNotificationService.shared.popLastMessage(),
            let type = info["type"] as? String {
            
            switch type {
            case "newPost":
                processNewPostPN(info, check: false)
            default:
                ()
            }
        }
    }
    
    private func processNewPostPN(_ info: [AnyHashable: Any], check: Bool = false) {
        if let id = info["experienceId"] as? String {
            ExperienceService.shared.loadExperience(experienceId: id) { [weak self] (experience, _) in
                guard let experience = experience else { return }
                DispatchQueue.main.async {
                    guard let explore = self?.viewControllers.first as? ExploreViewController else { return }
                    self?.popToRootViewController(animated: false)
                    explore.showExperience(experience: experience, check: check, scroll: true)
                }
            }
        }
    }
    
    private func processNewRequestPN(_ info: [AnyHashable: Any]) {
        if let id = info["senderId"] as? String {
            if let chat = ChatService.shared.getChat(for: id),
                let explore = viewControllers.first as? ExploreViewController {
                let vc = ChatViewController()
                _ = vc.view
                vc.setup(chat: chat)
                setViewControllers([explore, vc], animated: true)
            }
        }
    }
    
    private func processNewMessagePN(_ info: [AnyHashable: Any]) {
        if let chatId = info["chatId"] as? String {
            ChatService.shared.getChat(chatId: chatId, load: true) { [weak self] (chat) in
                if let chat = chat,
                    chat.members.count > 0,
                    chat.members.first(where: { $0.isMe() }) != nil {
                  //  ChatService.shared.addChat(chat: chat)
                    if let explore = self?.viewControllers.first as? ExploreViewController {
                        let showCall = (info["messageType"] as? String) == "startCall"
                   //     explore.showChat(chatId: chatId, showChat: !showCall, showCall: showCall)
                    }
                }
            }
        }
    }
    
    private func processDeeplinkPN(_ info: [AnyHashable: Any]) {
        if let strUrl = info["url"] as? String, let url = URL(string: strUrl) {
            DeepLinkService.shared.handle(url)
        }
    }
    
    private func processNewLikePN(_ info: [AnyHashable: Any]) {
        guard let id = info["experienceId"] as? String else { return }
        guard let explore = viewControllers.first as? ExploreViewController else { return }
        
        let ownProfile = OwnProfileViewController()
        _ = ownProfile.view
        ownProfile.backTap = { [weak self] in
            self?.popViewController(animated: true, subType: .fromRight)
        }
        
        setViewControllers([explore, ownProfile], animated: false)
        
        let nc = MoreTabBarNestedNavigationController()
        let vc = DesignedExperiencesViewController()
        _ = vc.view
        nc.setViewControllers([vc], animated: false)
        present(nc, animated: true, completion: { [weak vc] in
            vc?.showExperience(experienceId: id)
        })
    }

}
