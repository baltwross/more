//
//  CreateReviewModel.swift
//  More
//
//  Created by Luko Gjenero on 24/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class CreateReviewModel : Codable, Hashable {

    let id: String
    let time: Time
    var timeRate: Int? = nil
    var userRate: Int? = nil
    var userTags: [Review.Tag]? = nil
    var duration: Review.Duration? = nil
    var comment: String? = nil

    init(id: String = "",
         time: Time) {
        self.id = id
        self.time = time
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CreateReviewModel, rhs: CreateReviewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func review() -> Review { 
        return Review(
            id: "",
            creator: ProfileService.shared.profile?.user.short() ?? ShortUser(),
            createdAt: Date(),
            time: time.short(),
            timeRate: timeRate,
            userRate: userRate,
            comment: comment,
            userTags: userTags,
            duration: duration)
    }
    
}
