//
//  ExperienceMessage.swift
//  More
//
//  Created by Luko Gjenero on 26/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

struct ExperienceMessage: MoreDataObject {
    
    let id: String
    let createdAt: Date
    let creator: ShortUser
    let message: String
    
    init(id: String,
         createdAt: Date,
         creator: ShortUser,
         message: String) {
        
        self.id = id
        self.createdAt = createdAt
        self.creator = creator
        self.message = message
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperienceMessage, rhs: ExperienceMessage) -> Bool {
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
    
    static func fromJson(_ json: [String: Any]) -> ExperienceMessage? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let msg = try? JSONDecoder().decode(ExperienceMessage.self, from: jsonData) {
            return msg
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperienceMessage? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ExperienceMessage.fromJson(json)
        }
        return nil
    }

}
