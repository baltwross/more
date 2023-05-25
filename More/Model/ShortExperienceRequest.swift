//
//  ShortExperienceRequest.swift
//  More
//
//  Created by Luko Gjenero on 06/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

struct ShortExperienceRequest: MoreDataObject {
    
    let id: String
    let creator: ShortUser
    let post: ShortExperiencePost
    let accepted: Bool?
    
    init(id: String,
         creator: ShortUser,
         post: ShortExperiencePost,
         accepted: Bool? = nil) {
        
        self.id = id
        self.creator = creator
        self.post = post
        self.accepted = accepted
    }
    
    func requestWithId(_ id: String) -> ShortExperienceRequest {
        return ShortExperienceRequest(
            id: id,
            creator: creator,
            post: post,
            accepted: accepted)
    }
    
    func requestWithAccepted(_ accepted: Bool?) -> ShortExperienceRequest {
        return ShortExperienceRequest(
            id: id,
            creator: creator,
            post: post,
            accepted: accepted)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShortExperienceRequest, rhs: ShortExperienceRequest) -> Bool {
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
    
    static func fromJson(_ json: [String: Any]) -> ShortExperienceRequest? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let request = try? JSONDecoder().decode(ShortExperienceRequest.self, from: jsonData) {
            return request
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ShortExperienceRequest? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ShortExperienceRequest.fromJson(json)
        }
        return nil
    }

}
