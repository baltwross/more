//
//  ShortUser.swift
//  More
//
//  Created by Luko Gjenero on 01/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

struct ShortUser : MoreDataObject {
    
    let id: String
    let name: String
    let avatar: String
    let age: Int?
    
    init(id: String,
         name: String,
         avatar:String,
         age: Int? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.age = age
    }
    
    init() {
        self.init(id: "", name: "", avatar: "")
    }
    
    func isMe() -> Bool {
        return id == ProfileService.shared.profile?.id
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShortUser, rhs: ShortUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Data protocol
    
    var json: [String : Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> ShortUser? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let user = try? JSONDecoder().decode(ShortUser.self, from: jsonData) {
            return user
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ShortUser? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ShortUser.fromJson(json)
        }
        return nil
    }
    
    

}
