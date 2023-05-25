//
//  PushNotificationService.swift
//  More
//
//  Created by Luko Gjenero on 13/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseMessaging
import CoreLocation
import Firebase

class PushNotificationService: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    struct Notifications {
        static let PermissionsChanged = NSNotification.Name(rawValue: "com.more.push.changed")
        static let NotificationReceived = NSNotification.Name(rawValue: "com.more.push.notice")
        
        static let SignalMessage = NSNotification.Name(rawValue: "com.more.push.signal.message")
        static let SignalRequest = NSNotification.Name(rawValue: "com.more.push.signal.request")
        static let SignalResponse = NSNotification.Name(rawValue: "com.more.push.signal.response")
        static let TimeMessage = NSNotification.Name(rawValue: "com.more.push.time.message")
        
        
    }

    static let shared = PushNotificationService()
    
    private(set) var permissionsRequested: Bool = false
    private(set) var permissionsGranted: Bool = false
    private var lastMessassage: [AnyHashable: Any]? = nil
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: ProfileService.Notifications.ProfileLogin, object: nil)
        loadSettings()
        login()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }
    
    @objc private func toForeground() {
        loadSettings()
        
    }
    
    @objc private func toBackground() {
        // TODO
    }
    
    @objc private func login() {
        if let fcmToken = Messaging.messaging().fcmToken {
            ProfileService.shared.updateRegistrationToken(fcmToken)
        }
    }
    
    private func loadSettings() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] (settings) in
            
            switch settings.authorizationStatus {
            case .notDetermined:
                self?.permissionsRequested = false
                self?.permissionsGranted = false
            case .denied:
                self?.permissionsRequested = true
                self?.permissionsGranted = false
            case .authorized, .provisional:
                self?.permissionsRequested = true
                self?.permissionsGranted = true
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            default:
                ()
            }
            
            NotificationCenter.default.post(name: Notifications.PermissionsChanged, object: self)
        }
    }
    
    func requestPersmissions(_ complete: @escaping ()->()) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] (granted, error) in
            self?.permissionsRequested = true
            self?.permissionsGranted = granted
            NotificationCenter.default.post(name: Notifications.PermissionsChanged, object: self)
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            complete()
        }
    }
    
    // MARK: - locoal notifications
    
    func scheduleLocationNotification(identifier: String, location: GeoPoint, title:String, text: String) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = UNNotificationSound.default
        
        let region = CLCircularRegion(center: location.coordinates(), radius: 50.0, identifier: UUID().uuidString)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
    
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.add(request, withCompletionHandler: nil)
    }
    
    func scheduleTimerNotification(identifier: String, date: Date, title:String, text: String) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.add(request, withCompletionHandler: nil)
    }
    
    func removeLocalNotification(identifier: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - remote notice
    
    func notificationReceived(_ info: [AnyHashable: Any], handler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        
        // TODO: - in the future process something in background
        
        internalProcess(info: info)
        handler?(.noData)
    }
    
    // MARK: - user notifications
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let option: UNNotificationPresentationOptions = []
        completionHandler(option)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        internalProcess(info: response.notification.request.content.userInfo)
    }
    
    // MARK: - FCM
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            ProfileService.shared.updateRegistrationToken(token)
        }
    }

    


    
    // MARK: - processing
    
    func popLastMessage() -> [AnyHashable: Any]? {
        let last = lastMessassage
        lastMessassage = nil
        return last
    }
    
    private func internalProcess(info: [AnyHashable: Any]) {
        if UIApplication.shared.applicationState == .active {
            lastMessassage = info
            NotificationCenter.default.post(name: Notifications.NotificationReceived, object: self)
        } else if UIApplication.shared.applicationState == .inactive {
            lastMessassage = info
        } else if UIApplication.shared.applicationState == .background {
            lastMessassage = info
        }
        
    }
    
}
