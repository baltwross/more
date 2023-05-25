//
//  ExperienceRequest.swift
//  More
//
//  Created by Luko Gjenero on 26/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

struct ExperienceRequest: MoreDataObject {
    
    let id: String
    let createdAt: Date
    let creator: ShortUser
    let post: ShortExperiencePost
    let message: String?
    let accepted: Bool?
    
    init(id: String,
         createdAt: Date,
         creator: ShortUser,
         post: ShortExperiencePost,
         message: String?,
         accepted: Bool? = nil) {
        
        self.id = id
        self.createdAt = createdAt
        self.creator = creator
        self.post = post
        self.message = message
        self.accepted = accepted
    }
    
    func requestWithId(_ id: String) -> ExperienceRequest {
        return ExperienceRequest(
            id: id,
            createdAt: createdAt,
            creator: creator,
            post: post,
            message: message,
            accepted: accepted)
    }
    
    func requestWithAccepted(_ accepted: Bool?) -> ExperienceRequest {
        return ExperienceRequest(
            id: id,
            createdAt: createdAt,
            creator: creator,
            post: post,
            message: message,
            accepted: accepted)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperienceRequest, rhs: ExperienceRequest) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Helpers
    
    func short() -> ShortExperienceRequest {
        return ShortExperienceRequest(
            id: id,
            creator: creator,
            post: post,
            accepted: accepted)
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
    
    static func fromJson(_ json: [String: Any]) -> ExperienceRequest? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let request = try? JSONDecoder().decode(ExperienceRequest.self, from: jsonData) {
            return request
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperienceRequest? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ExperienceRequest.fromJson(json)
        }
        return nil
    }

}
