//
//  ReviewViewModel.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Foundation
import UIKit

class ReviewViewModel: Codable, Hashable, NSCopying {
    
    let id: String
    
    let time: ShortTime
    let creator: ShortUser
    
    let createdAt: Date
    let comment: String
    let rate: Int
    
    init(review: Review) {
        
        id = review.id
        
        time = review.time ?? ShortTime()
        /*
        time = ShortTime(id: review.id,
                         signal: ShortSignal(id: "--",
                                             text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                                             type: .boozy,
                                             expiresAt: Date(), creator: ShortUser(id: "", name: "", avatar: ""), imageUrls: nil),
                         createdAt: review.time?.createdAt ?? Date(),
                         endedAt: nil)
        */
        
        creator = review.creator

        createdAt = review.createdAt
        comment = review.comment ?? ""
        /*
        comment = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        */
        
        rate = review.timeRate ?? 0
    }
    
    private init(review: ReviewViewModel) {
        id = review.id
        time = review.time
        creator = review.creator
        createdAt = review.createdAt
        comment = review.comment
        rate = review.rate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ReviewViewModel, rhs: ReviewViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return ReviewViewModel(review: self)
    }
}
