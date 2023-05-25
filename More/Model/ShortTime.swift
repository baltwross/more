//
//  ShortTime.swift
//  More
//
//  Created by Luko Gjenero on 27/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

struct ShortTime: MoreDataObject {
    
    let id: String
    let signal: ShortSignal
    let requester: ShortUser
    let createdAt: Date
    let endedAt: Date?
    
    init(id: String,
         signal: ShortSignal,
         requester: ShortUser,
         createdAt: Date,
         endedAt: Date?) {
        
        self.id = id
        self.signal = signal
        self.requester = requester
        self.createdAt = createdAt
        self.endedAt = endedAt
    }
    
    init() {
        self.init(id: "", signal: ShortSignal(), requester: ShortUser(), createdAt: Date(), endedAt: nil)
    }
    
    func isMine() -> Bool {
        return signal.creator.isMe()
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShortTime, rhs: ShortTime) -> Bool {
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
    
    static func fromJson(_ json: [String: Any]) -> ShortTime? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let time = try? JSONDecoder().decode(ShortTime.self, from: jsonData) {
            return time
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ShortTime? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ShortTime.fromJson(json)
        }
        return nil
    }
    
}
