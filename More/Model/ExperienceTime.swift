//
//  ExperienceTime.swift
//  More
//
//  Created by Luko Gjenero on 07/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

enum ExperienceTimeState: String, Codable {
    case none, queryArrived, arrived, queryMet, met, cancelled, closed
}

class ExperienceTime: MoreDataObject {
    
    let id: String
    let createdAt: Date
    let expiresAt: Date
    let post: ShortExperiencePost
    let chat: ShortChat
    
    let meeting: GeoPoint?
    let locations: [String: GeoPoint]?
    let distances: [String: Double]?
    let states: [String: ExperienceTimeState]?
    
    init(id: String,
         createdAt: Date,
         expiresAt: Date,
         post: ShortExperiencePost,
         chat: ShortChat,
         meeting: GeoPoint? = nil,
         locations: [String: GeoPoint]? = nil,
         distances: [String: Double]? = nil,
         states: [String: ExperienceTimeState]? = nil) {
        
        self.id = id
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.post = post
        self.chat = chat
        self.meeting = meeting
        self.locations = locations
        self.distances = distances
        self.states = states
    }
    
    func timeWithMeeting(_ meeting: GeoPoint?) -> ExperienceTime {
        return ExperienceTime(id: id,
                              createdAt: createdAt,
                              expiresAt: expiresAt,
                              post: post,
                              chat: chat,
                              meeting: meeting,
                              locations: locations,
                              distances: distances,
                              states: states)
    }
    
    func timeWithLocations(_ locations: [String: GeoPoint]?) -> ExperienceTime {
        return ExperienceTime(id: id,
                              createdAt: createdAt,
                              expiresAt: expiresAt,
                              post: post,
                              chat: chat,
                              meeting: meeting,
                              locations: locations,
                              distances: distances,
                              states: states)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperienceTime, rhs: ExperienceTime) -> Bool {
        return lhs.id == rhs.id
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "meeting")
                json.removeValue(forKey: "locations")
                json.removeValue(forKey: "distances")
                json.removeValue(forKey: "states")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> ExperienceTime? {
        
        let meeting: GeoPoint? = json["meeting"] as? GeoPoint
        let locations: [String: GeoPoint]? = json["locations"] as? [String: GeoPoint]
        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "meeting")
        rectifiedJson.removeValue(forKey: "locations")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            let time = try? JSONDecoder().decode(ExperienceTime.self, from: jsonData) {
            return time.timeWithMeeting(meeting).timeWithLocations(locations)
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperienceTime? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ExperienceTime.fromJson(json)
        }
        return nil
    }
}

// MARK: - Helpers
extension ExperienceTime {
    
    func expired() -> Bool {
        // expired?
        let now = Date()
        if expiresAt < now {
            return true
        }
        return false
    }
    
    func haveLeft() -> Bool {
        // I have left?
        let myId = ProfileService.shared.profile?.id ?? "--"
        if let state = states?[myId], state == .cancelled || state == .closed {
            return true
        }
        if !chat.memberIds.contains(myId) {
            return true
        }
        return false
    }
    
    func allFinished() -> Bool {
        // All are finished?
        var allFinished = true
        for userId in chat.memberIds {
            let state = states?[userId]
            if state != .met && state != .cancelled && state != .closed {
                allFinished = false
                break
            }
        }
        return allFinished
    }
    
    func allExceptMeFinished() -> Bool {
        // All except me are finished
        let myId = ProfileService.shared.profile?.id ?? "--"
        var allExceptMeFinished = true
        for userId in chat.memberIds {
            guard userId != myId else { continue }
            let state = states?[userId]
            if state != .met && state != .cancelled && state != .closed {
                allExceptMeFinished = false
                break
            }
        }
        return allExceptMeFinished
    }
    
    func isFinished() -> Bool {
        return expired() || haveLeft() || allFinished()
    }
    
    func state() -> ExperienceTimeState {
        let myId = ProfileService.shared.profile?.id ?? "--"
        return states?[myId] ?? .none
    }
    
    func cancelled() -> Bool {
        // All except me have cancelled or closed
        let myId = ProfileService.shared.profile?.id ?? "--"
        var cancelled = true
        for userId in chat.memberIds {
            guard userId != myId else { continue }
            let state = states?[userId]
            if state != .cancelled && state != .closed {
                cancelled = false
                break
            }
        }
        return cancelled
    }
    
    
}

