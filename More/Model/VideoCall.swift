//
//  VideoCall.swift
//  More
//
//  Created by Luko Gjenero on 08/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import Firebase

class VideoCall: MoreDataObject {
    
    let id: String
    let sessionId: String
    let createdAt: Date
    let members: [ShortUser]
    
    init(id: String,
         sessionId: String,
         createdAt: Date,
         members: [ShortUser]) {
        self.id = id
        self.sessionId = sessionId
        self.createdAt = createdAt
        self.members = members
    }
    
    convenience init() {
        self.init(id: "", sessionId: "", createdAt: Date(), members: [])
    }
    
    func callWithMembers(_ members: [ShortUser]) -> VideoCall {
        return VideoCall(
            id: id,
            sessionId: sessionId,
            createdAt: createdAt,
            members: members)
    }
    
    func callWithId(_ id: String, _ sessionId: String) -> VideoCall {
        return VideoCall(
            id: id,
            sessionId: sessionId,
            createdAt: createdAt,
            members: members)
    }
    
    // Helpers
    
    func member(id: String) -> ShortUser? {
        return members.first { $0.id == id}
    }
    
    func IamMember() -> Bool {
        let myId = ProfileService.shared.profile?.getId() ?? "---"
        return member(id: myId) != nil
    }
    
    func sortedMembers() -> [ShortUser] {
        return members.sorted { (lhs, rhs) in lhs.isMe() ? false : rhs.isMe() ? true : lhs.id < rhs.id }
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: VideoCall, rhs: VideoCall) -> Bool {
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
    
    static func fromJson(_ json: [String : Any]) -> VideoCall? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let call = try? JSONDecoder().decode(VideoCall.self, from: jsonData) {
            return call
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> VideoCall? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return VideoCall.fromJson(json)
        }
        return nil
    }
    
}
