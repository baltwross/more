//
//  User.swift
//  More
//
//  Created by Luko Gjenero on 09/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Firebase


struct User: MoreDataObject {
    
    let id: String
    let name: String
    let avatar: String
    let quote: String?
    let quoteAuthor: String?
    let age: Int?
    
    let avgTimeReview: Float?
    let avgUserReview: Float?
    let numReview: Int?
    let numGoings: Int?
    let numDesigned: Int?
    let numLikes: Int?
    let lastReview: Review?
    var tags: [Review.Tag: Int]?
    
    // ....
    
    init(id: String,
         name: String,
         avatar:String,
         quote: String? = nil,
         quoteAuthor: String? = nil,
         age: Int? = nil,
         avgTimeReview: Float? = nil,
         avgUserReview: Float? = nil,
         numReview: Int? = nil,
         numGoings: Int? = nil,
         numDesigned: Int? = nil,
         numLikes: Int? = nil,
         lastReview: Review? = nil,
         tags: [Review.Tag: Int]? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.quote = quote
        self.quoteAuthor = quoteAuthor
        self.age = age
        self.avgTimeReview = avgTimeReview
        self.avgUserReview = avgUserReview
        self.numReview = numReview
        self.numGoings = numGoings
        self.numDesigned = numDesigned
        self.numLikes = numLikes
        self.lastReview = lastReview
        self.tags = tags
    }
    
    init() {
        self.init(id: "", name: "", avatar: "")
    }
    
    func isMe() -> Bool {
        return id == ProfileService.shared.profile?.id
    }
    
    func short() -> ShortUser {
        return ShortUser(id: id, name: name, avatar: avatar, age: age)
    }

    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Data protocol
    
    var json: [String : Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> User? {
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let user = try? JSONDecoder().decode(User.self, from: jsonData) {
            return user
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> User? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return User.fromJson(json)
        }
        return nil
    }
}
