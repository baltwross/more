//
//  ShortSignal.swift
//  More
//
//  Created by Luko Gjenero on 10/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

struct ShortSignal: MoreDataObject {
    
    let id: String
    let text: String
    let type: SignalType
    let expiresAt: Date
    let creator: ShortUser
    let images: [Image]
    
    init(id: String,
         text: String,
         type: SignalType,
         expiresAt: Date,
         creator: ShortUser,
         images: [Image] = []) {
        self.id = id
        self.text = text
        self.type = type
        self.expiresAt = expiresAt
        self.creator = creator
        self.images = images
    }
    
    init(signal: Signal) {
        self.id = signal.id
        self.text = signal.text
        self.type = signal.type
        self.expiresAt = signal.expiresAt
        self.creator = signal.creator.short()
        self.images = signal.images
    }
    
    init() {
        self.init(id: "", text: "", type: .adventurous, expiresAt: Date(), creator: ShortUser())
    }
    
    func isMine() -> Bool {
        return creator.isMe()
    }
    
    func shortSignalWithImages(_ images: [Image]) -> ShortSignal {
        return ShortSignal(id: id,
                           text: text,
                           type: type,
                           expiresAt: expiresAt,
                           creator: creator,
                           images: images)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShortSignal, rhs: ShortSignal) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Data protocol
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> ShortSignal? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let shortSignal = try? JSONDecoder().decode(ShortSignal.self, from: jsonData) {
            return shortSignal.shortSignalWithImages(shortSignal.images.sorted(by: { (lhs, rhs) -> Bool in
                return lhs.order > rhs.order
            }))
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ShortSignal? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ShortSignal.fromJson(json)
        }
        return nil
    }
}
