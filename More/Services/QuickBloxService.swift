//
//  QuickBloxService.swift
//  More
//
//  Created by Luko Gjenero on 08/01/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Quickblox
import QuickbloxWebRTC

private let kQBRingThickness: CGFloat = 1
private let kQBAnswerTimeInterval: TimeInterval = 60
private let kQBDialingTimeInterval: TimeInterval = 5

class QuickBloxService {

    static private let applicationID: UInt = 75391
    static private let authKey = "DVkbWAv3EbCNWxm"
    static private let authSecret  = "UujEBOSsRqqbPq9"
    static private let accountKey = "pKbxYttsFGek36kVv_q3"
    
    static let shared = QuickBloxService()
    
    init() {
        initialize()
    }
    
    private func initialize() {
        
        QBSettings.applicationID = QuickBloxService.applicationID
        QBSettings.authKey = QuickBloxService.authKey
        QBSettings.authSecret  = QuickBloxService.authSecret
        QBSettings.accountKey = QuickBloxService.accountKey
        // QBSettings.apiEndpoint = ""
        // QBSettings.chatEndpoint = ""
        
        QBRTCConfig.setAnswerTimeInterval(kQBAnswerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(kQBDialingTimeInterval)
        QBRTCConfig.setStatsReportTimeInterval(1)
        QBRTCConfig.setConferenceEndpoint("test")
        
        QBRTCClient.initializeRTC()
        
        // User login / logout
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: ProfileService.Notifications.ProfileLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: ProfileService.Notifications.ProfileLogout, object: nil)
        
        login()
    }
    
    @objc private func login() {
        guard let me = ProfileService.shared.profile else { return }
        
        func sanitize(_ phoneNumber: String) -> String {
            return phoneNumber.replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "-", with: "")
                    .replacingOccurrences(of: "+", with: "")
        }
        
        let user = QBUUser()
        user.login = me.id
        user.fullName = me.fullName()
        user.password = sanitize(me.formattedPhoneNumber)
        
        QBRequest.logIn(withUserLogin: user.login!, password: user.password!, successBlock: { [weak self] (response, user) in
            if response.isSuccess {
                // okay
                print("QB login")
            } else {
                self?.signin(user)
            }
        }, errorBlock: { [weak self] (response) in
            // nop
            // print("QB login error \(response.error)")
            self?.signin(user)
        })
    }
    
    private func signin(_ user: QBUUser) {
        QBRequest.signUp(user, successBlock: { response, user in
            // okay
            print("QB signup")
        }, errorBlock: { (response) in
            // nop
            print("QB sign in error \(response.error)")
        })
    }
    
    @objc private func logout() {
        QBRequest.logOut(successBlock: { (response) in
            print("QB logout")
        }, errorBlock: { (response) in
            // nop
        })
    }
    
}
