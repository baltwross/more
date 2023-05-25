//
//  ShortExperience.swift
//  More
//
//  Created by Luko Gjenero on 06/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

struct ShortExperience: MoreDataObject {
    
    let id: String
    let title: String
    let text: String
    let images: [Image]
    let type: SignalType
    let creator: ShortUser
    
    let isVirtual: Bool?
    let isPrivate: Bool?
    let tier: Product?
    
    init(id: String,
         title: String,
         text: String,
         images: [Image],
         type: SignalType,
         creator: ShortUser,
         isVirtual: Bool?,
         isPrivate: Bool?,
         tier: Product?) {
        
        self.id = id
        self.title = title
        self.text = text
        self.images = images
        self.type = type
        self.creator = creator
        self.isVirtual = isVirtual
        self.isPrivate = isPrivate
        self.tier = tier
    }
    
    func experienceWithImages(_ images: [Image]) -> ShortExperience {
        return ShortExperience(id: id,
                               title: title,
                               text: text,
                               images: images,
                               type: type,
                               creator: creator,
                               isVirtual: isVirtual,
                               isPrivate: isPrivate,
                               tier: tier)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShortExperience, rhs: ShortExperience) -> Bool {
        return lhs.id == rhs.id
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> ShortExperience? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let experience = try? JSONDecoder().decode(ShortExperience.self, from: jsonData) {
            return experience.experienceWithImages(experience.images.sorted(by: { (lhs, rhs) -> Bool in
                lhs.order < rhs.order
            }))
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ShortExperience? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ShortExperience.fromJson(json)
        }
        return nil
    }
}


