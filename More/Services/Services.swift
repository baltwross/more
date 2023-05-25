//
//  Services.swift
//  More
//
//  Created by Luko Gjenero on 14/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import FirebaseAuth

class Services {

    class func initialize(_ application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        
        _ = LocationService.shared
        _ = ProfileService.shared
        if Auth.auth().currentUser == nil {
            ProfileService.shared.logout(complete: nil)
        }
        _ = PushNotificationService.shared
        _ = ExperienceService.shared
        _ = ExperienceTrackingService.shared
        _ = TimesService.shared
        // _ = AlertService.shared
        _ = NetworkSpeedProvider.shared
        _ = ConfigService.shared
        _ = ChatService.shared
        _ = SignalSuggestionsService.shared
        _ = TwilioService.shared
        _ = VideoCallService.shared
        _ = InAppPurchaseService.shared
        DeepLinkService.shared.setupRoutes()
    }
    
}
