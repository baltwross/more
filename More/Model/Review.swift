//
//  Review.swift
//  More
//
//  Created by Luko Gjenero on 10/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

struct Review: MoreDataObject {
    
    enum Tag: String, Codable {
        case adventurous, open, curious, creative, respectful, funny
        
        static var all: [Tag] {
            return [.adventurous, .open, .curious, .creative, .respectful, .funny]
        }
        
        var description: String {
            switch self {
            case .adventurous:
                return "A lover of the world"
            case .open:
                return "Expressive and receptive"
            case .curious:
                return "Interested and passionate"
            case .creative:
                return "An interesting mind"
            case .respectful:
                return "Mindful of your boundaries"
            case .funny:
                return "Makes you laugh"
            }
        }
    }
    
    enum Duration: String, Codable {
        case underAnHour = "Under an hour"
        case oneToTwoHours = "1-2 hours"
        case threeToFourHours = "3-4 hours"
        case overFourHours = "Over 4 hours"
        
        static var all: [Duration] {
            return [.underAnHour, .oneToTwoHours, .threeToFourHours, .overFourHours]
        }
    }
    
    let id: String
    let creator: ShortUser
    let createdAt: Date
    let time: ShortTime
    
    let timeRate: Int?
    let userRate: Int?
    let comment: String?
    let userTags: [Tag]?
    let duration: Duration?
    
    init(id: String,
         creator: ShortUser,
         createdAt: Date,
         time: ShortTime,
         timeRate: Int? = nil,
         userRate: Int? = nil,
         comment: String? = nil,
         userTags: [Tag]? = nil,
         duration: Duration? = nil) {
        
        self.id = id
        self.creator = creator
        self.createdAt = createdAt
        self.time = time
        self.timeRate = timeRate
        self.userRate = userRate
        self.comment = comment
        self.userTags = userTags
        self.duration = duration
    }
    
    init(
        review: Review,
        time: ShortTime? = nil,
        timeRate: Int? = nil,
        userRate: Int? = nil,
        comment: String? = nil,
        userTags: [Tag]? = nil,
        duration: Duration? = nil) {
        
        self.init(
            id: review.id,
            creator: review.creator,
            createdAt: review.createdAt,
            time: time ?? review.time,
            timeRate: timeRate ?? review.timeRate,
            userRate: userRate ?? review.userRate,
            comment: comment ?? review.comment,
            userTags: userTags ?? review.userTags,
            duration: duration ?? review.duration)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Review, rhs: Review) -> Bool {
        return lhs.id == rhs.id
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> Review? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let review = try? JSONDecoder().decode(Review.self, from: jsonData) {
            return review
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Review? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Review.fromJson(json)
        }
        return nil
    }
    
}
