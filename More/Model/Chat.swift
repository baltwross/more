//
//  Chat.swift
//  More
//
//  Created by Luko Gjenero on 10/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

class Chat: MoreDataObject {
    
    enum ChatType: String, Codable {
        case single, group
    }
    
    let id: String
    let createdAt: Date
    let members: [ShortUser]
    let memberIds: [String: Bool]
    let type: ChatType?
    let messages: [Message]? // collection
    let typing: [String]
    let archived: Bool?
    
    // video call
    let videoCall: VideoCall?
    
    // creator
    let creator: ShortUser?
    
    init(id: String,
         createdAt: Date,
         members: [ShortUser],
         type: ChatType?,
         messages: [Message]?,
         typing: [String],
         archived: Bool? = nil,
         videoCall: VideoCall? = nil,
         creator: ShortUser? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.members = members
        var memberIds: [String: Bool] = [:]
        for member in members {
            memberIds[member.id] = true
        }
        self.memberIds = memberIds
        self.type = type
        self.messages = messages
        self.typing = typing
        self.archived = archived
        self.videoCall = videoCall
        self.creator = creator
    }
    
    convenience init() {
        self.init(id: "", createdAt: Date(), members: [], type: .single, messages: [], typing: [])
    }
    
    func chatWithMembers(_ members: [ShortUser]) -> Chat {
        return Chat(
            id: id,
            createdAt: createdAt,
            members: members,
            type: type,
            messages: messages,
            typing: typing,
            archived: archived,
            videoCall: videoCall,
            creator: creator)
    }
    
    func chatWithMessages(_ messages: [Message]?) -> Chat {
        return Chat(
            id: id,
            createdAt: createdAt,
            members: members,
            type: type,
            messages: messages,
            typing: typing,
            archived: archived,
            videoCall: videoCall,
            creator: creator)
    }
    
    func chatWithId(_ id: String) -> Chat {
        return Chat(
            id: id,
            createdAt: createdAt,
            members: members,
            type: type,
            messages: messages,
            typing: typing,
            archived: archived,
            videoCall: videoCall,
            creator: creator)
    }
    
    func chatWithType(_ type: ChatType?) -> Chat {
        return Chat(
            id: id,
            createdAt: createdAt,
            members: members,
            type: type,
            messages: messages,
            typing: typing,
            archived: archived,
            videoCall: videoCall,
            creator: creator)
    }
    
    func chatWithVideoCall(_ videoCall: VideoCall?) -> Chat {
        return Chat(
            id: id,
            createdAt: createdAt,
            members: members,
            type: type,
            messages: messages,
            typing: typing,
            archived: archived,
            videoCall: videoCall,
            creator: creator)
    }
    
    // Helpers
    
    func latestUpdate() -> Date {
        return latestMessage()?.createdAt ?? createdAt
    }
    
    func other() -> ShortUser {
        guard let myId = ProfileService.shared.profile?.getId() else { return ShortUser() }
        return members.first(where: { $0.id != myId }) ?? ShortUser()
    }
    
    func others() -> [ShortUser] {
        guard let myId = ProfileService.shared.profile?.getId() else { return [] }
        return members.filter { $0.id != myId }
    }
    
    func latestMessage() -> Message? {
        if let messages = messages,
            var latest = messages.first {
            for message in messages {
                if message.createdAt > latest.createdAt {
                    latest = message
                }
            }
            return latest
        }
        return nil
    }
    
    func latestMessage(of types: [MessageType]) -> Message? {
        let sorted = messages?.sorted { (lhs, rhs) -> Bool in
            return lhs.createdAt > rhs.createdAt
        }
        return sorted?.first(where: { (msg) -> Bool in
            return types.contains(msg.type)
        })
    }
    
    func short() -> ShortChat {
        return ShortChat(
            id: id,
            memberIds: Array(memberIds.keys),
            type: type)
    }
    
    func member(id: String) -> ShortUser? {
        return members.first { $0.id == id}
    }
    
    func IamMember() -> Bool {
        let myId = ProfileService.shared.profile?.getId() ?? "---"
        return memberIds[myId] != nil
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
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
    
    static func fromJson(_ json: [String : Any]) -> Chat? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let chat = try? JSONDecoder().decode(Chat.self, from: jsonData) {
            return chat
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Chat? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Chat.fromJson(json)
        }
        return nil
    }
    
}

// MARK: - helpers
extension Chat {
    
    class func getExperience(for chat: Chat) -> Experience? {
        let now = Date()
        for experience in ExperienceTrackingService.shared.getActiveExperiences() {
            if let post = experience.myPost(), post.isActive(now) {
                if post.chat?.id == chat.id ||
                    (chat.members.count == 2 && !(chat.type == .group) && post.request(from: chat.other().id) != nil) {
                    return experience
                }
            }
            if let request = experience.myRequest(),
                let post = experience.post(for: request.id), post.isActive(now) {
                if post.chat?.id == chat.id ||
                    (chat.members.count == 2 && !(chat.type == .group) && post.creator.id == chat.other().id) {
                    return experience
                }
            }
        }
        return nil
    }
    
    class func getPost(for chat: Chat) -> ExperiencePost? {
        let now = Date()
        for experience in ExperienceTrackingService.shared.getActiveExperiences() {
            if let post = experience.myPost(), post.isActive(now) {
                if post.chat?.id == chat.id ||
                    (chat.members.count == 2 && !(chat.type == .group) && post.request(from: chat.other().id) != nil) {
                    return post
                }
            }
            if let request = experience.myRequest(),
                let post = experience.post(for: request.id), post.isActive(now) {
                if post.chat?.id == chat.id ||
                    (chat.members.count == 2 && !(chat.type == .group) && post.creator.id == chat.other().id) {
                    return post
                }
            }
        }
        return nil
    }
    
    class func getRequest(for chat: Chat) -> ExperienceRequest? {
        if let post = getPost(for: chat) {
            if chat.members.count == 2 {
                return post.myRequest() ?? post.request(from: chat.other().id)
            }
        }
        return nil
    }
    
    class func getTime(for chat: Chat) -> ExperienceTime? {
        for time in TimesService.shared.getTrackedTimes() {
            if time.chat.id == chat.id {
                return time
            }
        }
        return nil
    }
}
