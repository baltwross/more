//
//  ExperienceLog.swift
//  More
//
//  Created by Luko Gjenero on 26/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

struct ExperienceLog: MoreDataObject {
    
    let id: String
    let createdAt: Date
    let time: ExperienceTime
    let images: [Image]
    let messages: [ExperienceMessage]? // collection ?
    
    init(id: String,
         createdAt: Date,
         time: ExperienceTime,
         images: [Image],
         messages: [ExperienceMessage]?) {
        
        self.id = id
        self.createdAt = createdAt
        self.time = time
        self.images = images
        self.messages = messages
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperienceLog, rhs: ExperienceLog) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Data protocol
    
    var json: [String : Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                json.removeValue(forKey: "messages")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> ExperienceLog? {
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let log = try? JSONDecoder().decode(ExperienceLog.self, from: jsonData) {
            return log
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperienceLog? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ExperienceLog.fromJson(json)
        }
        return nil
    }

}

extension ExperienceLog {
    
    func experience() -> Experience {
        
        let creator = User(id: time.post.experience.creator.id, name: time.post.experience.creator.name, avatar: time.post.experience.creator.avatar)
        let date = Date()
        
        return Experience(
            id: id,
            title: time.post.experience.title,
            text: time.post.experience.text,
            images: time.post.experience.images,
            type: time.post.experience.type,
            isVirtual: false,
            isPrivate: false,
            tier: nil,
            creator: creator,
            createdAt: date,
            expiresAt: date,
            radius: nil,
            schedule: nil,
            destination: nil,
            destinationName: nil,
            destinationAddress: nil,
            anywhere: nil,
            neighbourhood: nil,
            city: nil,
            state: nil)
        
    }
    
}
