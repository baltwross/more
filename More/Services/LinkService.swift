//
//  LinkService.swift
//  More
//
//  Created by Luko Gjenero on 06/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Firebase
import Branch

class LinkService {
    
    // TODO: - Branch links - to remove
    
    class func inviteLink(complete: @escaping (_ url: URL)->()) {
        
        let id = ProfileService.shared.profile?.getId()
        
        let linkProperties = BranchLinkProperties()
        linkProperties.channel = "app_invite"
        let branchUniveralObject = BranchUniversalObject()
        branchUniveralObject.title = "More Invite"
        branchUniveralObject.contentDescription = "Join me on More!"
        branchUniveralObject.imageUrl = Urls.logo
        
        if let id = id {
            branchUniveralObject.contentMetadata.customMetadata["action"] = "referral"
            branchUniveralObject.contentMetadata.customMetadata["referralId"] = "\(id)"
        }
        branchUniveralObject.contentMetadata.customMetadata["source"] = "iOS"
        branchUniveralObject.getShortUrl(with: linkProperties, andCallback: { (url, error) in
            DispatchQueue.main.async {
                guard let url = url, url.count > 0 else {
                    complete(URL(string: "https://www.startwithmore.com")!)
                    return
                }
                complete(URL(string: url)!)
            }
        })
    }
    
    class func shareExperienceLink(experience: Experience, complete: @escaping (_ url: URL)->()) {
        
        let deeplink = "startwithmore://experience?id=\(experience.id)"
        
        let linkProperties = BranchLinkProperties()
        linkProperties.channel = "app_signal"
        linkProperties.addControlParam("deeplink", withValue: deeplink)
        
        let branchUniveralObject = BranchUniversalObject()
        branchUniveralObject.title = experience.title
        branchUniveralObject.contentDescription = experience.text
        branchUniveralObject.imageUrl = experience.images.first?.url ?? Urls.logo
            
        branchUniveralObject.contentMetadata.customMetadata["deeplink"] = deeplink
        branchUniveralObject.contentMetadata.customMetadata["source"] = "iOS"
        
        branchUniveralObject.getShortUrl(with: linkProperties, andCallback: { (url, error) in
            DispatchQueue.main.async {
                guard let url = url, url.count > 0 else {
                    complete(URL(string: "https://www.startwithmore.com")!)
                    return
                }
                complete(URL(string: url)!)
            }
        })
    }

    // TODO: - Firebase Dynamic links - need support for iOS Unversal Links

    /*
 
    class func inviteLink(complete: @escaping (_ url: URL)->()) {
        
        let defaultUrl = URL(string: "https://startwithmore.page.link")!
        
        guard let id = ProfileService.shared.profile?.getId() else {
            complete(defaultUrl)
            return
        }
        
        let baseURL = URL(string: "startwithmore://referral?id=\(id)")!
        let domain = "https://startwithmore.page.link"
        
        if let linkBuilder = DynamicLinkComponents(link: baseURL, domainURIPrefix: domain) {
            
            linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.startwithmore.more")
            linkBuilder.shorten { (shortURL, warnings, error) in
                let url = shortURL ?? linkBuilder.url ?? defaultUrl
                complete(url)
            }
        } else {
            complete(defaultUrl)
        }
    }
    
    class func shareSignalLink(signalId: String, complete: @escaping (_ url: URL)->()) {
        
        let defaultUrl = URL(string: "https://startwithmore.page.link")!
        let baseURL = URL(string: "startwithmore://signal?id=\(signalId)")!
        let domain = "https://startwithmore.page.link"
        
        if let linkBuilder = DynamicLinkComponents(link: baseURL, domainURIPrefix: domain) {
            
            linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.startwithmore.more")
            linkBuilder.iOSParameters?.customScheme = "startwithmore"
            linkBuilder.shorten { (shortURL, warnings, error) in
                let url = shortURL ?? linkBuilder.url ?? defaultUrl
                complete(url)
            }
        } else {
            complete(defaultUrl)
        }
    }
    */
}
