//
//  ExperiencePost.swift
//  More
//
//  Created by Luko Gjenero on 26/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

enum MeetType: String, Codable {
    case none, destination, halfway, near
}

struct ExperiencePost: MoreDataObject {
    
    let id: String
    let createdAt: Date
    let expiresAt: Date
    let creator: User
    let experience: ShortExperience
    let title: String?
    let text: String
    let images: [Image]
    let chat: ShortChat?
    let started: Bool
    let location: GeoPoint?
    let meeting: GeoPoint?
    let meetingName: String?
    let meetingAddress: String?
    let meetingType: MeetType?
    let isSilent: Bool?
    
    
    let requests: [ExperienceRequest]? // collection ?
    
    init(id: String,
         createdAt: Date,
         expiresAt: Date,
         creator: User,
         experience: ShortExperience,
         title: String?,
         text: String,
         images: [Image],
         chat: ShortChat?,
         started: Bool,
         location: GeoPoint? = nil,
         meeting: GeoPoint? = nil,
         meetingName: String? = nil,
         meetingAddress: String? = nil,
         meetingType: MeetType? = nil,
         isSilent: Bool? = nil,
         requests: [ExperienceRequest]? = nil) {
        
        self.id = id
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.creator = creator
        self.experience = experience
        self.title = title
        self.text = text
        self.images = images
        self.chat = chat
        self.started = started
        self.location = location
        self.meeting = meeting
        self.meetingName = meetingName
        self.meetingAddress = meetingAddress
        self.meetingType = meetingType
        self.isSilent = isSilent
        self.requests = requests
    }
    
    func postWithId(_ id: String) -> ExperiencePost {
        return ExperiencePost(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            creator: creator,
            experience: experience,
            title: title,
            text: text,
            images: images,
            chat: chat,
            started: started,
            location: location,
            meeting: meeting,
            meetingName: meetingName,
            meetingAddress: meetingAddress,
            meetingType: meetingType,
            isSilent: isSilent,
            requests: requests)
    }
    
    func postWithLocation(_ location: GeoPoint?) -> ExperiencePost {
        return ExperiencePost(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            creator: creator,
            experience: experience,
            title: title,
            text: text,
            images: images,
            chat: chat,
            started: started,
            location: location,
            meeting: meeting,
            meetingName: meetingName,
            meetingAddress: meetingAddress,
            meetingType: meetingType,
            isSilent: isSilent,
            requests: requests)
    }
    
    func postWithMeeting(_ meeting: GeoPoint?) -> ExperiencePost {
        return ExperiencePost(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            creator: creator,
            experience: experience,
            title: title,
            text: text,
            images: images,
            chat: chat,
            started: started,
            location: location,
            meeting: meeting,
            meetingName: meetingName,
            meetingAddress: meetingAddress,
            meetingType: meetingType,
            isSilent: isSilent,
            requests: requests)
    }
    
    func postWithMeetingNameAndTypeAndAddress(_ meetingName: String?, _ meetingType: MeetType?, _ meetingAddress: String?) -> ExperiencePost {
        return ExperiencePost(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            creator: creator,
            experience: experience,
            title: title,
            text: text,
            images: images,
            chat: chat,
            started: started,
            location: location,
            meeting: meeting,
            meetingName: meetingName,
            meetingAddress: meetingAddress,
            meetingType: meetingType,
            isSilent: isSilent,
            requests: requests)
    }
    
    func postWithRequests(_ requests: [ExperienceRequest]?) -> ExperiencePost {
        return ExperiencePost(
            id: id,
            createdAt: createdAt,
            expiresAt: expiresAt,
            creator: creator,
            experience: experience,
            title: title,
            text: text,
            images: images,
            chat: chat,
            started: started,
            location: location,
            meeting: meeting,
            meetingName: meetingName,
            meetingType: meetingType,
            isSilent: isSilent,
            requests: requests)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperiencePost, rhs: ExperiencePost) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Helper
    
    func isActive(_ date: Date) -> Bool {
        return date < expiresAt
    }
    
    func isNear() -> Bool {
        if let location = location,
            let myLocation = LocationService.shared.currentLocation {
            
            return myLocation.distance(from: location.location()) <= ConfigService.shared.experienceSearchRadius
        }
        return false
    }
    
    static func create(experience: Experience, user: User, isSilent: Bool) -> ExperiencePost {
        let now = Date()
        return ExperiencePost(
            id: "",
            createdAt: now,
            expiresAt: now.addingTimeInterval(ConfigService.shared.experiencePostExpiration),
            creator: user,
            experience: experience.short(),
            title: experience.title,
            text: experience.text,
            images: [],
            chat: nil,
            started: false,
            isSilent: isSilent)
    }
    
    func short() -> ShortExperiencePost {
        return ShortExperiencePost(
            id: id,
            creator: creator.short(),
            experience: experience,
            title: title,
            text: text,
            images: images,
            isSilent: isSilent)
    }
    
    func request(from creatorId: String) -> ExperienceRequest? {
        return requests?.first(where: { $0.creator.id == creatorId })
    }
    
    func myRequest() -> ExperienceRequest? {
        return request(from: ProfileService.shared.profile?.id ?? "--")
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                json.removeValue(forKey: "location")
                json.removeValue(forKey: "meeting")
                json.removeValue(forKey: "requests")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> ExperiencePost? {
        let location: GeoPoint? = json["location"] as? GeoPoint
        let meeting: GeoPoint? = json["meeting"] as? GeoPoint
        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "location")
        rectifiedJson.removeValue(forKey: "meeting")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            let post = try? JSONDecoder().decode(ExperiencePost.self, from: jsonData) {
            return post.postWithLocation(location).postWithMeeting(meeting)
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperiencePost? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ExperiencePost.fromJson(json)
        }
        return nil
    }
}
