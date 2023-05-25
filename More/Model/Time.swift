//
//  Time.swift
//  More
//
//  Created by Luko Gjenero on 10/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

// 2 weeks in seconds
private let reviewDeadline: TimeInterval = 1.21e+6

enum TimeState: String, Codable {
    case none, queryArrived, arrived, queryMet, met, cancelled, closed
}

struct Time: MoreDataObject {

    let id: String
    let signal: ShortSignal
    let requester: ShortUser
    let createdAt: Date
    let creatorState: TimeState?
    let creatorCancelMessage: String?
    let creatorLocation: GeoPoint?
    let requesterState: TimeState?
    let requesterCancelMessage: String?
    let requesterLocation: GeoPoint?
    let endedAt: Date?
    
    let meeting: GeoPoint?
    
    let reviews: [Review]? // collection
    
    init(id: String,
         signal: ShortSignal,
         requester: ShortUser,
         createdAt: Date,
         creatorState: TimeState? = nil,
         creatorCancelMessage: String? = nil,
         creatorLocation: GeoPoint? = nil,
         requesterState: TimeState? = nil,
         requesterCancelMessage: String? = nil,
         requesterLocation: GeoPoint? = nil,
         endedAt: Date? = nil,
         meeting: GeoPoint? = nil,
         reviews: [Review]? = nil) {
        
        self.id = id
        self.signal = signal
        self.requester = requester
        self.createdAt = createdAt
        self.creatorState = creatorState
        self.creatorCancelMessage = creatorCancelMessage
        self.creatorLocation = creatorLocation
        self.requesterState = requesterState
        self.requesterCancelMessage = requesterCancelMessage
        self.requesterLocation = requesterLocation
        self.endedAt = endedAt
        self.meeting = meeting
        self.reviews = reviews
    }
    
    func timeWithCreatorState(_ creatorState: TimeState?) -> Time {
        return Time(
            id: id,
            signal: signal,
            requester: requester,
            createdAt: createdAt,
            creatorState: creatorState,
            creatorCancelMessage: creatorCancelMessage,
            creatorLocation: creatorLocation,
            requesterState: requesterState,
            requesterCancelMessage: requesterCancelMessage,
            requesterLocation: requesterLocation,
            endedAt: endedAt,
            meeting: meeting,
            reviews: reviews)
    }
    
    func timeWithRequesterState(_ requesterState: TimeState?) -> Time {
        return Time(
            id: id,
            signal: signal,
            requester: requester,
            createdAt: createdAt,
            creatorState: creatorState,
            creatorCancelMessage: creatorCancelMessage,
            creatorLocation: creatorLocation,
            requesterState: requesterState,
            requesterCancelMessage: requesterCancelMessage,
            requesterLocation: requesterLocation,
            endedAt: endedAt,
            meeting: meeting,
            reviews: reviews)
    }
    
    func timeWithReviews(_ reviews: [Review]?) -> Time {
        return Time(
            id: id,
            signal: signal,
            requester: requester,
            createdAt: createdAt,
            creatorState: creatorState,
            creatorCancelMessage: creatorCancelMessage,
            creatorLocation: creatorLocation,
            requesterState: requesterState,
            requesterCancelMessage: requesterCancelMessage,
            requesterLocation: requesterLocation,
            endedAt: endedAt,
            meeting: meeting,
            reviews: reviews)
    }
    
    func timeWithMeeting(_ meeting: GeoPoint) -> Time {
        return Time(
            id: id,
            signal: signal,
            requester: requester,
            createdAt: createdAt,
            creatorState: creatorState,
            creatorCancelMessage: creatorCancelMessage,
            creatorLocation: creatorLocation,
            requesterState: requesterState,
            requesterCancelMessage: requesterCancelMessage,
            requesterLocation: requesterLocation,
            endedAt: endedAt,
            meeting: meeting,
            reviews: reviews)
    }
    
    func timeWithCreatorLocation(_ creatorLocation: GeoPoint) -> Time {
        return Time(
            id: id,
            signal: signal,
            requester: requester,
            createdAt: createdAt,
            creatorState: creatorState,
            creatorCancelMessage: creatorCancelMessage,
            creatorLocation: creatorLocation,
            requesterState: requesterState,
            requesterCancelMessage: requesterCancelMessage,
            requesterLocation: requesterLocation,
            endedAt: endedAt,
            meeting: meeting,
            reviews: reviews)
    }
    
    func timeWithRequesterLocation(_ requesterLocation: GeoPoint) -> Time {
        return Time(
            id: id,
            signal: signal,
            requester: requester,
            createdAt: createdAt,
            creatorState: creatorState,
            creatorCancelMessage: creatorCancelMessage,
            creatorLocation: creatorLocation,
            requesterState: requesterState,
            requesterCancelMessage: requesterCancelMessage,
            requesterLocation: requesterLocation,
            endedAt: endedAt,
            meeting: meeting,
            reviews: reviews)
    }
    
    func timeWithEndedAt(_ endedAt: Date) -> Time {
        return Time(
            id: id,
            signal: signal,
            requester: requester,
            createdAt: createdAt,
            creatorState: creatorState,
            creatorCancelMessage: creatorCancelMessage,
            creatorLocation: creatorLocation,
            requesterState: requesterState,
            requesterCancelMessage: requesterCancelMessage,
            requesterLocation: requesterLocation,
            endedAt: endedAt,
            meeting: meeting,
            reviews: reviews)
    }
    
    func myReview() -> Review? {
        return reviews?.first(where: { $0.creator.isMe() })
    }
    
    func otherReview() -> Review? {
        return reviews?.first(where: { $0.creator.id == otherPerson().id })
    }
    
    func haveReviewed() -> Bool {
        return myReview() != nil
    }
    
    func otherHasReviewed() -> Bool {
        return otherReview() != nil
    }
    
    func reviewsUnlocked() -> Bool {
        return (haveReviewed() && otherHasReviewed()) || finalExpiration() < Date()
    }
    
    func finalExpiration() -> Date {
        
        if !(haveReviewed() && otherHasReviewed()) {
            return createdAt.addingTimeInterval(reviewDeadline)
        }
        return createdAt
    }
    
    func otherPerson() -> ShortUser {
        if isMine() {
            return requester
        }
        return signal.creator
    }
    
    func state() -> TimeState {
        if isMine() {
            return creatorState ?? .none
        }
        return requesterState ?? .none
    }
    
    func otherState() -> TimeState {
        if isMine() {
            return requesterState ?? .none
        }
        return creatorState ?? .none
    }
    
    func isMine() -> Bool {
        return signal.creator.isMe()
    }
    
    func shouldTrackLocation() -> Bool {
        return state() != .met && otherState() != .met &&
            state() != .cancelled && otherState() != .cancelled &&
            state() != .closed && otherState() != .closed &&
            (endedAt == nil || endedAt! > Date())
    }
    
    func otherCancelMessage() -> String? {
        if isMine() {
            return requesterCancelMessage
        }
        return creatorCancelMessage
    }
    
    func short() -> ShortTime {
        return ShortTime(
            id: id,
            signal: signal,
            requester: requester,
            createdAt: createdAt,
            endedAt: endedAt)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.id == rhs.id
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                json.removeValue(forKey: "reviews")
                json.removeValue(forKey: "meeting")
                json.removeValue(forKey: "creatorLocation")
                json.removeValue(forKey: "requesterLocation")
                
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> Time? {
        
        let meeting: GeoPoint? = json["meeting"] as? GeoPoint
        let creator: GeoPoint? = json["creatorLocation"] as? GeoPoint
        let requester: GeoPoint? = json["requesterLocation"] as? GeoPoint
        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "meeting")
        rectifiedJson.removeValue(forKey: "creatorLocation")
        rectifiedJson.removeValue(forKey: "requesterLocation")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            var time = try? JSONDecoder().decode(Time.self, from: jsonData) {
            
            let reviews: [Review] = Time.convertListBack(json["reviewList"] as? [String: Any]) ?? []
            time = time.timeWithReviews(reviews)
            
            if let meeting = meeting {
                time = time.timeWithMeeting(meeting)
            }
            
            if let creator = creator {
                time = time.timeWithCreatorLocation(creator)
            }
            
            if let requester = requester {
                time = time.timeWithRequesterLocation(requester)
            }
            
            return time
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Time? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Time.fromJson(json)
        }
        return nil
    }
    
}
