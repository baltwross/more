//
//  ConfigService.swift
//  More
//
//  Created by Luko Gjenero on 14/01/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig


class ConfigService: NSObject {

    static let shared = ConfigService()
    
    private var remoteConfig = RemoteConfig.remoteConfig()
    
    struct Notifications {
        static let ConfigLoaded = NSNotification.Name(rawValue: "com.more.config.loaded")
    }
    
    // MARK: - properties
    
    @objc dynamic var signalExpiration: TimeInterval = 1800
    @objc dynamic var signalRequestExpiration: TimeInterval = 300
    @objc dynamic var signalSearchRadius: Double = 10000
    
    @objc dynamic var experiencePostExpiration: TimeInterval = 1800
    @objc dynamic var experienceRequestExpiration: TimeInterval = 300
    @objc dynamic var experienceSearchRadius: Double = 1000
    @objc dynamic var experienceLimit: Int = 15
    
    @objc dynamic var experienceRefreshTime: TimeInterval = 180
    @objc dynamic var experienceRefreshLocation: Double = 200
    
    @objc dynamic var likesThreshold: Int = 5
    @objc dynamic var canRemoveLike: Bool = true
    @objc dynamic var sharesThreshold: Int = 5
    
    @objc dynamic var chatPhotoEnabled: Bool = true
    @objc dynamic var chatVideoEnabled: Bool = true
    @objc dynamic var chatVideoDuration: TimeInterval = 15
    @objc dynamic var chatVideoQuality: String = "low"
    
    @objc dynamic var removeWhenAndWhereFromCreate: Bool = true
    
    @objc dynamic var experienceVideoEnabled: Bool = true
    @objc dynamic var experienceVideoDuration: TimeInterval = 15
    @objc dynamic var experienceVideoQuality: String = "low"
    
    // MARK: - tests
    
    @objc dynamic var experienceTopBarVariation: Bool = false
    
    @objc dynamic var showTutorials: Bool = false
    
    // MARK: - init
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        setup()
        toForeground()
    }
    
    @objc private func toForeground() {
        fetch(nil)
    }
    
    @objc private func toBackground() {
        // nothing
    }
    
    // MARK: - setup variables
    
    private func setup() {
        
        // configs
        let remoteConfigSettings = RemoteConfigSettings()
        remoteConfig.configSettings = remoteConfigSettings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        applyRemoteConfig()
    }
    
    // MARK: - remote config
    
    private var isFetching = false
    
    func fetch(retries: Int = 0, _ completeBlock: ((_ success: Bool) -> Void)?) {
        var proceed = true
        synced(self) {
            if self.isFetching {
                proceed = false
            } else {
                self.isFetching = true
            }
        }
        
        if retries > 2 {
            completeBlock?(false)
        }
        
        if proceed {
            remoteConfig.fetchAndActivate { [weak self] (status, error) in
                switch status {
                case .successFetchedFromRemote, .successUsingPreFetchedData:
                    self?.applyRemoteConfig()
                    completeBlock?(true)
                case .error:
                    self?.fetch(retries: retries + 1, completeBlock)
                @unknown default:
                    ()
                }

                if let sself = self {
                    synced(sself) {
                        sself.isFetching = false
                    }
                }
            }
        }
    }
    private func applyRemoteConfig() {
        for case let (label?, value) in Mirror(reflecting: self).children {
            if !nonConfigProperties.contains(label) {
                switch String(describing: type(of: value)) {
                case "__NSCFBoolean", "Swift.Bool", "Bool":
                    self.setValue(remoteConfig[label].boolValue, forKey: label)
                    break
                case "__NSCFNumber", "Swift.Int", "Int", "Double":
                    self.setValue(remoteConfig[label].numberValue, forKey: label)
                    break
                default: // String
                    self.setValue(remoteConfig[label].stringValue!, forKey: label)
                    break
                }
            }
        }
    }
    
    // MARK: - helper
    
    private let nonConfigProperties: [String] =
        ["shared",
         "remoteConfig",
         "isFetching",
         "nonConfigProperties"]
}
