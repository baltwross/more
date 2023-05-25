//
//  Constants.swift
//  More
//
//  Created by Anirudh Bandi on 7/10/18.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Foundation
import UIKit

let places_api_key = "AIzaSyD6XeygiBH6XP-CwIt4kQ-aWBm4pA1hr3Y"

struct Storyboard {
    static let main : String = "Main"
    static let login : String = "Login"
}

struct Colors {
    static let background: UIColor = UIColor(red: 230, green: 230, blue: 230)
    static let topBarBackground: UIColor = UIColor(red: 230, green: 230, blue: 230)
    static let topBarText: UIColor = UIColor(red: 67, green: 74, blue: 81)
    static let bottomBarBackground: UIColor = UIColor(red: 255, green: 255, blue: 255)
    
    // MARK: avatar
    static let avatarInnerRing: UIColor = UIColor(red: 244, green: 244, blue: 244)
    static let avatarOuterRing: UIColor = UIColor(red: 191, green: 195, blue: 202)
    
    // MARK: explore
    static let exploreText: UIColor = UIColor(red: 68, green: 74, blue: 80)
    static let exploreDockBackground: UIColor = UIColor(red: 244, green: 244, blue: 244)
    
    // MARK: profile
    static let tagBackground: UIColor = UIColor(red: 238, green: 238, blue: 238)
    static let lightBlueHighlight: UIColor = UIColor(red: 3, green: 202, blue: 255)
    static let profilekBackground: UIColor = UIColor(red: 244, green: 244, blue: 244)
    
    static let reviewItemOddBackground: UIColor = UIColor(red: 58, green: 61, blue: 67)
    
    // MARK: messaging
    static let incomingBubble: UIColor = UIColor(red: 232, green: 235, blue: 238)
    static let outgoingBubble: UIColor = UIColor(red: 97, green: 145, blue: 255)
    static let inputPlaceholder: UIColor = UIColor(red: 191, green: 195, blue: 202)
    static let inputText: UIColor = UIColor(red: 67, green: 74, blue: 81)
    
    
    // MARK: create signal
    static let selectImageButtonBorder: UIColor = UIColor(red: 245, green: 245, blue: 254)
    static let quoteInputPlaceholder: UIColor = UIColor(red: 191, green: 195, blue: 202)
    
    static let previewLightBackground: UIColor = UIColor(red: 218, green: 221, blue: 226)
    static let previewLightText: UIColor = UIColor(red: 40, green: 40, blue: 43)
    static let previewDarkBackground: UIColor = UIColor(red: 40, green: 40, blue: 43)
    static let previewDarkText: UIColor = UIColor(red: 255, green: 255, blue: 255)
    
    static let moodSelectedTitle: UIColor = UIColor(red: 124, green: 139, blue: 155)
    static let moodNotSelectedTitle: UIColor = UIColor(red: 191, green: 195, blue: 202)
}


struct Urls {
    static let support = "https://www.startwithmore.com/support"
    static let terms = "https://www.startwithmore.com/terms"
    static let privacy = "https://www.startwithmore.com/privacy"
    static let legal = "https://www.startwithmore.com/legal"
    static let welcomeVideo = "https://startwithmore.wistia.com/embed/medias/v1ib3g9vxi.m3u8"
    static let logo = "https://firebasestorage.googleapis.com/v0/b/moretest-274fe.appspot.com/o/FCMImages%2Fmore_logo.png?alt=media&token=a1eb100b-579e-4a4f-95e1-fbc89c7ce2a3"
}

struct Emails {
    static let support = "help@startwithmore.com"
}

struct MapBox {
    // static let styleUrl = "mapbox://styles/moreanastasiya/cjohmlun4008v2so3pk2o9x8f"
    static let styleUrl = "mapbox://styles/moreanastasiya/cjpr91f5h6b482smb38a820wq"
    static let enrouteStyleUrl = "mapbox://styles/moreanastasiya/cjpog31u43opb2so8v7omftys"
}

struct Id {
    static let More = "moreteam"
}

struct Config {
    struct Experience {
        static let virtualSpots = 12
    }
}
