//
//  Request.swift
//  More
//
//  Created by Luko Gjenero on 02/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

struct Request: Codable, Hashable, MoreDataObject {
    
    let id: String
    let createdAt: Date
    let expiresAt: Date
    let signal: ShortSignal
    let sender: ShortUser
    let location: GeoPoint?
    let accepted: Bool?
    let message: String?
    
    init(id: String,
         createdAt: Date,
         expiresAt: Date,
         signal: ShortSignal,
         sender: ShortUser,
         location: GeoPoint?,
         accepted: Bool?,
         message: String?) {
        
        self.id = id
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.signal = signal
        self.sender = sender
        self.location = location
        self.accepted = accepted
        self.message = message
    }
    
    func requestWithAccepted(_ accepted: Bool?) -> Request {
        return Request(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            signal: signal,
            sender: sender,
            location: location,
            accepted: accepted,
            message: message)
    }
    
    func requestWithLocation(_ location: GeoPoint?) -> Request {
        return Request(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            signal: signal,
            sender: sender,
            location: location,
            accepted: accepted,
            message: message)
    }
    
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.id == rhs.id
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                json.removeValue(forKey: "location")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> Request? {
        
        let location: GeoPoint? = json["location"] as? GeoPoint
        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "location")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            let request = try? JSONDecoder().decode(Request.self, from: jsonData) {
            return request.requestWithLocation(location)
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Request? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Request.fromJson(json)
        }
        return nil
    }
    
    
}
