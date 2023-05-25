//
//  Message.swift
//  More
//
//  Created by Luko Gjenero on 02/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

enum MessageType: String, Codable {
    case welcome, text, photo, video, request, expired, accepted, met, review, created, meeting, joined, startCall
}

struct Message: MoreDataObject {
    
    let id: String
    let createdAt: Date
    let sender: ShortUser
    let type: MessageType
    let text: String
    let additionalData: String?
    var deliveredAt: [String: Date]?
    var readAt: [String: Date]?
    
    init(id: String,
        createdAt: Date,
        sender: ShortUser,
        type: MessageType,
        text: String,
        additionalData: String? = nil,
        deliveredAt: [String: Date]?,
        readAt: [String: Date]?) {
        
        self.id = id
        self.createdAt = createdAt
        self.sender = sender
        self.type = type
        self.text = text
        self.additionalData = additionalData
        self.deliveredAt = deliveredAt
        self.readAt = readAt
    }
    
    func isMine() -> Bool {
        return sender.isMe()
    }
    
    // helper
    
    func haveRead() -> Bool {
        let myId = ProfileService.shared.profile?.id ?? "-"
        return readAt?[myId] != nil
    }
    
    func wasDelivered() -> Bool {
        let myId = ProfileService.shared.profile?.id ?? "-"
        return deliveredAt?[myId] != nil
    }
    
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
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
    
    static func fromJson(_ json: [String: Any]) -> Message? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let message = try? JSONDecoder().decode(Message.self, from: jsonData) {
            return message
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Message? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Message.fromJson(json)
        }
        return nil
    }
}

// MARK: - additional data
extension Message {
    
    static func additionalData(from additional: [AnyHashable: Any]) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: additional, options:[]),
            let stringJson = String(data: data, encoding: String.Encoding.utf8) {
            return stringJson
        } else {
            return nil
        }
    }
    
    func additional() -> [AnyHashable: Any]? {
        if let data = additionalData?.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any] {
            return json
        }
        return nil
    }
}

// MARK: - video/photo data
extension Message {
    
    func additionalUrl() -> String? {
        if let additional = additional(),
            let media = additional["media"] as? [AnyHashable: Any],
            let url = media["url"] as? String {
            return url
        }
        return nil
    }
    
    func additionalPath() -> String? {
        if let additional = additional(),
            let media = additional["media"] as? [AnyHashable: Any],
            let path = media["path"] as? String {
            return path
        }
        return nil
    }
    
    func additionalPreviewUrl() -> String? {
        if let additional = additional(),
            let media = additional["media"] as? [AnyHashable: Any],
            let url = media["previewUrl"] as? String {
            return url
        }
        return nil
    }
    
    func additionalPreviewPath() -> String? {
        if let additional = additional(),
            let media = additional["media"] as? [AnyHashable: Any],
            let path = media["previewPath"] as? String {
            return path
        }
        return nil
    }
    
    static func additionalMediaData(url: String, path: String, previewUrl: String? = nil, previewPath: String? = nil) -> [AnyHashable: Any] {
        var media = ["url": url, "path": path]
        if let previewUrl =  previewUrl, let previewPath = previewPath {
            media["previewUrl"] = previewUrl
            media["previewPath"] = previewPath
        }
        var additional: [AnyHashable: Any] = [:]
        additional["media"] = media
        return additional
    }
}

// MARK: - meeting data
extension Message {
    
    func additionalMeetingLocation() -> GeoPoint? {
        if let additional = additional(),
            let location = additional["location"] as? [AnyHashable: Any],
            let latitude = location["latitude"] as? Double,
            let longitude = location["longitude"] as? Double {
            return GeoPoint(latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    func additionalMeetingName() -> String? {
        return additional()?["name"] as? String
    }
    
    func additionalMeetingAddress() -> String? {
        return additional()?["address"] as? String
    }
    
    static func additionalMeetingData(location: GeoPoint, name: String, address: String) -> [AnyHashable: Any] {
        var additional: [AnyHashable: Any] = [:]
        additional["location"] = ["latitude": location.latitude, "longitude": location.longitude]
        additional["name"] = name
        additional["address"] = address
        return additional
    }
}

// MARK: - virtual time
extension Message {
    
    func additionalVirtualTimeId() -> String? {
        return additional()?["virtualTimeId"] as? String
    }
    
    func additionalVirtualTimeTitle() -> String? {
        return additional()?["virtualTimeTitle"] as? String
    }
    
    static func additionalVirtualTimeData(id: String, title: String) -> [AnyHashable: Any] {
        var additional: [AnyHashable: Any] = [:]
        additional["virtualTimeId"] = id
        additional["virtualTimeTitle"] = title
        return additional
    }
}
