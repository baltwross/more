//
//  AppDelegate.swift
//  More
//
//  Created by Anirudh Bandi on 6/12/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import Siren
// import SDWebImage
// import Nuke
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static func appDelegate() -> AppDelegate? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set the status bar style to light content
          //UIApplication.shared.statusBarStyle = .lightContent
        application.isIdleTimerDisabled = false
        
        // UI
        UIConfig.setup()
        
        // In app purchases (must be called before Firebase configure)
        IAPHelper.shared.lingeringProductCompleteBlock = { transaction in
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        // APIs
        GMSPlacesClient.provideAPIKey(places_api_key)
        FirebaseApp.configure()
        
        // Services
        Services.initialize(application, launchOptions)
        
        // UI utils and custom setup
        MoreUI.initialize()
        
        // Branch
        BranchService.shared.initialize(launchOptions: launchOptions)
        
//        // Test
//        SDImageCache.shared.clearDisk(onCompletion: nil)
//        ImageCache.shared.removeAll()
//        DataLoader.sharedUrlCache.removeAllCachedResponses()
//        TutorialService.shared.clearTutorials()
        
        // inital view
        if ProfileService.shared.profilePhase != .ready {
            let login = LoginNavigationController()
            window?.rootViewController = login
        } else {
            
            // NOT using Tab controller anymore
            /*
            let tab = MoreTabBarController()
            _  = tab.view
            tab.waitWithSplash()
            window?.rootViewController = tab
            */
            
            let nc = MoreTabBarNestedNavigationController()
            let vc = ExploreViewController()
            nc.viewControllers = [vc]
            nc.waitWithSplash()
            window?.rootViewController = nc
        }
        
        /*
        window?.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginInviteToGetInViewController")
        
        let statusBar = UIView(frame: UIApplication.shared.statusBarFrame)
          statusBar.backgroundColor = UIColor.clear
          UIApplication.shared.windows.first?.addSubview(statusBar)
        */
        Siren.shared.wail()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let branchDidHandle = BranchService.shared.openApplicationURL(
            application: application,
            url: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
        var deeplinkDidHandle = false
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            if let link = dynamicLink.url {
                deeplinkDidHandle = DeepLinkService.shared.handle(link)
            }
        }
        
        return branchDidHandle || deeplinkDidHandle || DeepLinkService.shared.handle(url)
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let branchDidHandle = BranchService.shared.continueUserActivity(userActivity)

        let deeplinkDidHandle = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if let link = dynamiclink?.url {
                DeepLinkService.shared.handle(link)
            }
        }
        return branchDidHandle || deeplinkDidHandle
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func transitionRootViewController(viewController: UIViewController?, animated: Bool, completion: ((Bool) -> Void)?) {
        
        UIView.transition(with: window!, duration: animated ? 0.5 : 0.0, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = viewController
        }) { (finished) in
            if completion != nil {
                completion!(finished)
            }
        }
    }
    
    // MARK: - PNs
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // store token
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        ProfileService.shared.updateDeviceToken(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // nothing
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PushNotificationService.shared.notificationReceived(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationService.shared.notificationReceived(userInfo, handler: completionHandler)
    }
    
    // MARK: - background fetch
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2, execute: {
            completionHandler(.noData)
        })
    }
}

