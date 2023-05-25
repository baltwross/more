//
//  ShortExperiencePost.swift
//  More
//
//  Created by Luko Gjenero on 06/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

struct ShortExperiencePost: MoreDataObject {
    
    let id: String
    let creator: ShortUser
    let experience: ShortExperience
    let title: String?
    let text: String
    let images: [Image]
    let isSilent: Bool?
    
    init(id: String,
         creator: ShortUser,
         experience: ShortExperience,
         title: String?,
         text: String,
         images: [Image],
         isSilent: Bool?) {
        
        self.id = id
        self.creator = creator
        self.experience = experience
        self.title = title
        self.text = text
        self.images = images
        self.isSilent = isSilent
    }
    
    func postWithImages(_ images: [Image]) -> ShortExperiencePost {
        return ShortExperiencePost(
            id: id,
            creator: creator,
            experience: experience,
            title: title,
            text: text,
            images: images,
            isSilent: isSilent)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShortExperiencePost, rhs: ShortExperiencePost) -> Bool {
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
    
    static func fromJson(_ json: [String: Any]) -> ShortExperiencePost? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let post = try? JSONDecoder().decode(ShortExperiencePost.self, from: jsonData) {
            return post.postWithImages(post.images.sorted(by: { (lhs, rhs) -> Bool in
                lhs.order < rhs.order
            }))
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ShortExperiencePost? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ShortExperiencePost.fromJson(json)
        }
        return nil
    }
}
