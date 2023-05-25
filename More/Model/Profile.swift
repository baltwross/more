//
//  Profile.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Firebase

struct Profile: MoreDataObject {
    
    // authentication data
    let phoneNumber: String
    let formattedPhoneNumber: String
    var authVerificationID: String?
    var verificationCode: String?
    
    // User data
    var id: String = ""
    var iOSDeviceToken: String? = nil
    var registrationToken: String? = nil
    var referral: String? = nil
    var terms: Bool = false
    var firstName: String? = nil
    var lastName: String? = nil
    var email: String? = nil
    var instagram: String? = nil
    var memories: String? = nil
    var inviteLink: String? = nil
    
    var verified: Bool = true // need to see how exactly we'll manage this flag (means user does not need to wait to get in)
    
    var images: [Image]? = nil // collection
    var birthday: Date? = nil
    var quote: String? = nil
    var quoteAuthor: String? = nil
    var gender: String? = nil
    
    var reviews: [Review]? = nil // collection
    var numberOfGoings: Int? = nil
    var numberOfDesigned: Int? = nil
    var numberOfLikes: Int? = nil
    
    var isAdmin: Bool? = nil
    
    var nonSpentPurchases: Double? = nil
    
    func getId() -> String? {
        if id.isEmpty {
            return nil
        }
        return id
    }
    
    func age() -> Int? {
        guard let birthday = birthday else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthday, to: Date())
        return components.year
    }
    
    func fullName() -> String {
        var full = ""
        if let first = firstName {
            full += first
        }
        if let last = lastName {
            full += " \(last)"
        }
        return full
    }
    
    func avgTimeRate() -> Float? {
        guard let reviews = reviews, reviews.count > 0 else { return nil }
        var sum: Int = 0
        for review in reviews {
            sum += review.timeRate ?? 0
        }
        return Float(sum) / Float(reviews.count)
    }
    
    func avgUserRate() -> Float? {
        guard let reviews = reviews, reviews.count > 0 else { return nil }
        var sum: Int = 0
        for review in reviews {
            sum += review.userRate ?? 0
        }
        return Float(sum) / Float(reviews.count)
    }
    
    func numReview() -> Int {
        return reviews?.count ?? 0
    }
    
    func tags() -> [Review.Tag: Int] {
        guard let reviews = reviews, reviews.count > 0 else { return [:] }
        var tags: [Review.Tag: Int] = [:]
        for review in reviews {
            guard let userTags = review.userTags, userTags.count > 0 else { continue }
            for tag in userTags {
                if let num = tags[tag] {
                    tags[tag] = num + 1
                } else {
                    tags[tag] = 1
                }
            }
        }
        return tags
    }
    
    func lastReview() -> Review? {
        guard let reviews = reviews, reviews.count > 0 else { return nil }
        var last: Review = reviews.first!
        for review in reviews {
            if last.createdAt < review.createdAt {
                last = review
            }
        }
        return last
    }
    
    init(phoneNumber: String, formattedPhoneNumber: String, authVerificationID: String?) {
        self.phoneNumber = phoneNumber
        self.formattedPhoneNumber = formattedPhoneNumber
        self.authVerificationID = authVerificationID
    }
    
    var user: User {
        return User(
            id: id,
            name: firstName ?? "",
            avatar: images?.first?.url ?? "",
            quote: quote,
            quoteAuthor: quoteAuthor,
            age: age(),
            avgTimeReview: avgTimeRate(),
            avgUserReview: avgUserRate(),
            numReview: numReview(),
            numGoings: numberOfGoings ?? 0,
            numDesigned: numberOfDesigned ?? 0,
            numLikes: numberOfLikes ?? 0,
            lastReview: lastReview(),
            tags: tags())
    }
    
    var shortUser: ShortUser { 
        return ShortUser(
            id: id,
            name: firstName ?? "",
            avatar: images?.first?.url ?? "",
            age: age())
    }
    
    mutating func update(from profile: Profile) {
        self.referral = profile.referral
        self.terms = profile.terms
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.email = profile.email
        self.instagram = profile.instagram
        self.memories = profile.memories
        self.inviteLink = profile.inviteLink
        self.verified = profile.verified
        self.images = profile.images
        self.birthday = profile.birthday
        self.quote = profile.quote
        self.quoteAuthor = profile.quoteAuthor
        self.gender = profile.gender
        self.reviews = profile.reviews
        self.numberOfGoings = profile.numberOfGoings
        self.numberOfDesigned = profile.numberOfDesigned
        self.numberOfLikes = profile.numberOfLikes
        self.isAdmin = profile.isAdmin
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                json.removeValue(forKey: "authVerificationID")
                json.removeValue(forKey: "verificationCode")
                json.removeValue(forKey: "reviews")
                json.removeValue(forKey: "images")
                
                return json
            }
            return nil
        }
        set {
            guard let newValue = newValue else { return }
            if let profile = Profile.fromJson(newValue) {
                self.referral = profile.referral
                self.terms = profile.terms
                self.firstName = profile.firstName
                self.lastName = profile.lastName
                self.email = profile.email
                self.instagram = profile.instagram
                self.memories = profile.memories
                self.inviteLink = profile.inviteLink
                self.verified = profile.verified
                self.images = profile.images
                self.birthday = profile.birthday
                self.quote = profile.quote
                self.quoteAuthor = profile.quoteAuthor
                self.gender = profile.gender
                self.reviews = profile.reviews
                self.numberOfGoings = profile.numberOfGoings
                self.numberOfDesigned = profile.numberOfDesigned
                self.numberOfLikes = profile.numberOfLikes
                self.isAdmin = profile.isAdmin
            }
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> Profile? {

        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "location")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            var profile = try? JSONDecoder().decode(Profile.self, from: jsonData) {
            profile.reviews = convertListBack(json["reviewList"] as? [String: Any])
            profile.images = convertListBack(json["imageList"] as? [String: Any])
            return profile
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Profile? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Profile.fromJson(json)
        }
        return nil
    }
}
