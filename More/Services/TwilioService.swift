//
//  TwilioService.swift
//  More
//
//  Created by Luko Gjenero on 17/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import Firebase

private let kQBRingThickness: CGFloat = 1
private let kQBAnswerTimeInterval: TimeInterval = 60
private let kQBDialingTimeInterval: TimeInterval = 5

class TwilioService {

    static private let applicationID = "1680561442ed842"
    static private let apiKey = "4aca6b532e7174906781d38a5f69a0f8497656c0"
    static private let region: String = "us"
    static private let authSecret  = "UujEBOSsRqqbPq9"
    static private let accountKey = "pKbxYttsFGek36kVv_q3"
    
    static let shared = TwilioService()
    
    private (set) var token: String?
    
    init() {
        initialize()
    }
    
    private func initialize() {
        
        // User login / logout
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: ProfileService.Notifications.ProfileLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: ProfileService.Notifications.ProfileLogout, object: nil)

        login()
    }
    
    @objc private func login() {
        guard let me = ProfileService.shared.profile else { return }
        
        Functions.functions().httpsCallable("getTwilioToken")
            .call(["userId": me.id]) { [weak self] (result, error) in
                if let data = result?.data as? [String: Any],
                    let token = data["token"] as? String {
                    print("Twilio token received: \(token)")
                    self?.token = token
                } else {
                    print("Twilio token error: \(error?.localizedDescription)")
                }
        }
    }
    
    @objc private func logout() {
        token = nil
    }
}
