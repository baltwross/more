//
//  ExperienceTip.swift
//  More
//
//  Created by Luko Gjenero on 26/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

struct ExperienceTip: MoreDataObject {
    
    let id: String
    let creator: ShortUser
    let createdAt: Date
    let text: String
    let upvote: [String]?
    let downvote: [String]?
    
    init(
        id: String = "",
        creator: ShortUser,
        createdAt: Date,
        text: String,
        upvote: [String]?,
        downvote: [String]?) {
        
        self.id = id
        self.creator = creator
        self.createdAt = createdAt
        self.text = text
        self.upvote = upvote
        self.downvote = downvote
    }
    
    func tipWithId(_ id: String) -> ExperienceTip {
        return ExperienceTip(
            id: id,
            creator: creator,
            createdAt: createdAt,
            text: text,
            upvote: upvote,
            downvote: downvote)
    }
    
    func tipWithVotes(upvote: [String]?, downvote: [String]?) -> ExperienceTip {
        return ExperienceTip(
            id: id,
            creator: creator,
            createdAt: createdAt,
            text: text,
            upvote: upvote,
            downvote: downvote)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperienceTip, rhs: ExperienceTip) -> Bool {
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
    
    static func fromJson(_ json: [String: Any]) -> ExperienceTip? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let tip = try? JSONDecoder().decode(ExperienceTip.self, from: jsonData) {
            return tip
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperienceTip? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ExperienceTip.fromJson(json)
        }
        return nil
    }
    

}
