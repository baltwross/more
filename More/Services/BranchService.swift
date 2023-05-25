//
//  BranchService.swift
//  More
//
//  Created by Luko Gjenero on 11/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Branch

class BranchService {
    
    struct Notifications {
        static let ReferralIDLoaded = NSNotification.Name(rawValue: "com.more.branch.referralId")
    }
    
    static let shared = BranchService()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        toForeground()
    }
    
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { [weak self] params, error in
            
            if let params = params {
                
                //  check referral ID
                if let action = params["action"] as? String, action == "referral",
                    let referralId = params["referralId"] as? String {
                    self?.referralId = referralId
                    NotificationCenter.default.post(name: Notifications.ReferralIDLoaded, object: self, userInfo: ["referralId": referralId])
                }
                
                // check deeplink
                if let deeplink = params["deeplink"] as? String, let url = URL(string: deeplink) {
                    DeepLinkService.shared.handle(url)
                }
            }
            
            if error == nil {
                // DEBUG
                print("params: %@", params as? [String: AnyObject] ?? {})
            }
        })
    }
    
    func openApplicationURL(application: UIApplication, url: URL, sourceApplication: String?, annotation: Any?) -> Bool {
        return Branch.getInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool {
        return Branch.getInstance().continue(userActivity)
    }
    
    
    
    // MARK: - referral storage
    
    private let referralIdKey = "com.more.branch.referralId"
    
    private(set) var referralId: String?
    
    @objc private func toForeground() {
        referralId = UserDefaults.standard.string(forKey: referralIdKey)
    }
    
    @objc private func toBackground() {
        UserDefaults.standard.set(referralId, forKey: referralIdKey)
    }
    
}
