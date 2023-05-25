//
//  UserViewModel.swift
//  More
//
//  Created by Luko Gjenero on 09/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Firebase

class UserViewModel: Codable {

    let id: String
    let name: String
    let fullName: String
    let age: Int
    let memory: String
    
    let imageUrls: [String]
    let quote: String
    let quoteAuthor: String
    let avgReview: Float
    let numOfReviews: Int
    let numOfGoings: Int
    let numOfDesigned: Int
    
    let tags: [Review.Tag: Int]
    
    let reviews: [ReviewViewModel]
    
    // ....
    
    var avatarUrl: String {
        return imageUrls.first ?? ""
    }
    
    init(user: User) {
        id = user.id
        name = user.name
        fullName = user.name
        age = user.age ?? 0
        memory = ""

        imageUrls = [user.avatar]
        
        quote = user.quote ?? ""
        quoteAuthor = user.quoteAuthor ?? ""
        avgReview = user.avgTimeReview ?? 0
        numOfReviews = user.numReview ?? 0
        numOfGoings = user.numGoings ?? 0
        numOfDesigned = user.numDesigned ?? 0
        
        tags = user.tags ?? [:]
        
        reviews = []
    }
    
    init(user: ShortUser) {
        id = user.id
        name = user.name
        fullName = user.name
        age = user.age ?? 0
        memory = ""
        
        imageUrls = [user.avatar]
        
        quote = ""
        quoteAuthor = ""
        avgReview = 0
        numOfReviews = 0
        numOfGoings = 0
        numOfDesigned = 0
        
        tags = [:]
        
        reviews = []
    }
    
    init(profile: Profile) {
        
        id = profile.id
        name = profile.firstName ?? ""
        fullName = profile.fullName()
        age = profile.age() ?? 0
        memory = profile.memories ?? ""
        
        if let images = profile.images, images.count > 0 {
            imageUrls = images.map { $0.url }
        } else {
            imageUrls = []
        }
        
        quote = profile.quote ?? ""
        quoteAuthor = profile.quoteAuthor ?? ""
        
        avgReview = profile.avgTimeRate() ?? 0
        numOfReviews = profile.numReview()
        numOfGoings = profile.numberOfGoings ?? 0
        numOfDesigned = profile.numberOfDesigned ?? 0
        
        tags = profile.tags()
        
        reviews = profile.reviews?.map { ReviewViewModel(review: $0) } ?? []
    }
    
    var user: User {
        return User(id: id, name: name, avatar: avatarUrl)
    }
    
}
