//
//  CometChatService.swift
//  More
//
//  Created by Luko Gjenero on 10/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import CometChatPro

private let kQBRingThickness: CGFloat = 1
private let kQBAnswerTimeInterval: TimeInterval = 60
private let kQBDialingTimeInterval: TimeInterval = 5

class CometChatService {

    static private let applicationID = "1680561442ed842"
    static private let apiKey = "4aca6b532e7174906781d38a5f69a0f8497656c0"
    static private let region: String = "us"
    static private let authSecret  = "UujEBOSsRqqbPq9"
    static private let accountKey = "pKbxYttsFGek36kVv_q3"
    
    
    static let shared = CometChatService()
    
    init() {
        initialize()
    }
    
    private func initialize() {
                
        // initialize
        let mySettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: CometChatService.region).build()
        
        _ = CometChat(appId: CometChatService.applicationID ,appSettings: mySettings,onSuccess: { (isSuccess) in
            if (isSuccess) {
                print("CometChat Pro SDK intialise successfully.")
            }
        }, onError: { (error) in
            print("CometChat Pro SDK failed intialise with error: \(error.errorDescription)")
        })
        
        
        // User login / logout
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: ProfileService.Notifications.ProfileLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: ProfileService.Notifications.ProfileLogout, object: nil)
        
        login()
    }
    
    @objc private func login() {
        guard let me = ProfileService.shared.profile else { return }
        
        if let user = CometChat.getLoggedInUser() {
            print("CometChat User logged in: " + user.stringValue())
        } else {
            CometChat.login(UID: me.id, apiKey: CometChatService.apiKey, onSuccess: { (user) in
                print("CometChat Login successful : " + user.stringValue())
            }, onError: { [weak self] (error) in
                self?.signin()
            })
        }
    }
    
    private func signin() {
        guard let me = ProfileService.shared.profile else { return }
        
        let newUser = CometChatPro.User(uid: me.id, name: me.firstName ?? "?")
        CometChat.createUser(user: newUser, apiKey: CometChatService.apiKey, onSuccess: { [weak self] (user) in
            print("CometChat User signed in: " + user.stringValue())
            self?.login()
        }, onError: { (error) in
            print("CometChat sign in error: \(String(describing: error?.description))")
        })
    }
    
    @objc private func logout() {
        CometChat.logout(onSuccess: { (_) in
            print("CometChat logout")
        }, onError: { (error) in
            print("CometChat logout error: \(String(describing: error.description))")
        })
    }
    
}
