//
//  ExperienceLike.swift
//  More
//
//  Created by Luko Gjenero on 21/02/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import Firebase

class ExperienceLike: MoreDataObject {
    
    let id: String
    let experience: ShortExperience
    let creator: ShortUser
    let createdAt: Date
    
    init(id: String,
         experience: ShortExperience,
         creator: ShortUser,
         createdAt: Date) {
        
        self.id = id
        self.experience = experience
        self.creator = creator
        self.createdAt = createdAt
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(experience.id)
        hasher.combine(creator.id)
    }
    
    static func == (lhs: ExperienceLike, rhs: ExperienceLike) -> Bool {
        return lhs.experience.id == rhs.experience.id && lhs.creator.id == rhs.creator.id
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
    
    static func fromJson(_ json: [String: Any]) -> ExperienceLike? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let like = try? JSONDecoder().decode(ExperienceLike.self, from: jsonData) {
            return like
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperienceLike? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ExperienceLike.fromJson(json)
        }
        return nil
    }

}
