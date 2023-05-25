//
//  ShortChat.swift
//  More
//
//  Created by Luko Gjenero on 07/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

class ShortChat: MoreDataObject {
    
    let id: String
    let memberIds: [String]
    let type: Chat.ChatType?
    
    init(id: String,
         memberIds: [String],
         type: Chat.ChatType?) {
        self.id = id
        self.memberIds = memberIds
        self.type = type
    }
    
    func chatWithMemberIds(_ memberIds: [String]) -> ShortChat {
        return ShortChat(
            id: id,
            memberIds: memberIds,
            type: type)
    }
    
    // Helpers
    
    func IamMember() -> Bool {
        let myId = ProfileService.shared.profile?.getId() ?? "---"
        return memberIds.contains(myId)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShortChat, rhs: ShortChat) -> Bool {
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
    
    static func fromJson(_ json: [String : Any]) -> ShortChat? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let chat = try? JSONDecoder().decode(ShortChat.self, from: jsonData) {
            return chat
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ShortChat? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ShortChat.fromJson(json)
        }
        return nil
    }
    
}
