//
//  MoreError.swift
//  More
//
//  Created by Luko Gjenero on 27/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class MoreError {
    
    static let domain = "AppErrorDomain"
    
    enum Codes: Int {
        case notLoggedIn = -1
        case postAlreadyCreated = 1
        case callAlreadyFull = 2
    }
    
    class func notLoggedIn() -> NSError {
        return NSError(
            domain: domain,
            code: Codes.notLoggedIn.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: "Not logged in"
            ]
        )
    }
    
    class func postCreated() -> NSError {
        return NSError(
            domain: domain,
            code: Codes.postAlreadyCreated.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: "Experience already active"
            ]
        )
    }
    
    class func callFull() -> NSError {
        return NSError(
            domain: domain,
            code: Codes.callAlreadyFull.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: "Room already full"
            ]
        )
    }
    

}
