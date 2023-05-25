//
//  ShareService.swift
//  More
//
//  Created by Luko Gjenero on 06/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ShareService {
    
    class func shareInvite(from vc: UIViewController) {
        guard let linkString = ProfileService.shared.profile?.inviteLink,
            let link = URL(string: linkString)
            else {
                vc.showLoading()
                LinkService.inviteLink { (url) in
                    DispatchQueue.main.async {
                        vc.hideLoading()
                        ProfileService.shared.updateInviteLink(url.absoluteString)
                        shareInvite(from: vc)
                    }
                }
                return
        }
        
        let subject = "Join Me On More"
        let body = "Have you tried More? Meet new people, have adventures. Get the app now! - "
        
        let activityVC = UIActivityViewController(activityItems: [body, link], applicationActivities: nil)
        activityVC.setValue(subject, forKey: "Subject")
        let excludeActivities: [UIActivity.ActivityType] = [.print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo]
        activityVC.excludedActivityTypes = excludeActivities
        activityVC.completionWithItemsHandler = { (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ activityError: Error?) -> Void in
            // nothing
        }
        vc.present(activityVC, animated: true, completion: { })
    }
    
    class func shareSignal(link: URL, from vc: UIViewController, complete: ((_ success: Bool)->())? = nil) {
        
        let subject = "Join Me On More"
        let body = "Let's do this thing together. Get the app now and meet me there! - "
        
        let activityVC = UIActivityViewController(activityItems: [body, link], applicationActivities: nil)
        activityVC.setValue(subject, forKey: "Subject")
        let excludeActivities: [UIActivity.ActivityType] = [.print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo]
        activityVC.excludedActivityTypes = excludeActivities
        activityVC.completionWithItemsHandler = { (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ activityError: Error?) -> Void in
            complete?(completed)
        }
        vc.present(activityVC, animated: true, completion: { })
    }

}
