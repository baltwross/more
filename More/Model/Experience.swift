//
//  Experience.swift
//  More
//
//  Created by Luko Gjenero on 26/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase
import IGListKit

class Experience: MoreDataObject {
    
    let id: String
    let title: String
    let text: String
    let images: [Image]
    
    let type: SignalType
    
    let isVirtual: Bool?
    let isPrivate: Bool?
    let tier: Product?

    let creator: User
    let createdAt: Date
    let expiresAt: Date
    
    let radius: Double?
    let schedule: ExperienceSchedule?
    
    let destination: GeoPoint?
    let destinationName: String?
    let destinationAddress: String?
    
    let anywhere: Bool?
    let neighbourhood: String?
    let city: String?
    let state: String?
    
    let numOfLikes: Int?
    let numOfShares: Int?
    
    let posts: [ExperiencePost]? // collection ?
    let history: [ExperienceLog]? // collection ?
    let tips: [ExperienceTip]? // collection ?
    
    init(id: String,
         title: String,
         text: String,
         images: [Image],
         type: SignalType,
         isVirtual: Bool?,
         isPrivate: Bool?,
         tier: Product?,
         creator: User,
         createdAt: Date,
         expiresAt: Date,
         radius: Double?,
         schedule: ExperienceSchedule?,
         destination: GeoPoint?,
         destinationName: String?,
         destinationAddress: String?,
         anywhere: Bool?,
         neighbourhood: String?,
         city: String?,
         state: String?,
         numOfLikes: Int? = nil,
         numOfShares: Int? = nil,
         posts: [ExperiencePost]? = nil,
         history: [ExperienceLog]? = nil,
         tips: [ExperienceTip]? = nil) {
        
        self.id = id
        self.title = title
        self.text = text
        self.images = images
        self.type = type
        self.isVirtual = isVirtual
        self.isPrivate = isPrivate
        self.tier = tier
        self.creator = creator
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.radius = radius
        self.schedule = schedule
        self.destination = destination
        self.destinationName = destinationName
        self.destinationAddress = destinationAddress
        self.neighbourhood = neighbourhood
        self.anywhere = anywhere
        self.city = city
        self.state = state
        self.numOfLikes = numOfLikes
        self.numOfShares = numOfShares
        self.posts = posts
        self.history = history
        self.tips = tips
    }
    
    func experienceWithId(_ id: String) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    func experienceWithPosts(_ posts: [ExperiencePost]?) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    func experienceWithHistory(_ history: [ExperienceLog]?) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    func experienceWithTips(_ tips: [ExperienceTip]?) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    func experienceWithDestination(_ destination: GeoPoint?) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    func experienceWithImages(_ images: [Image]) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    func experienceWithSchedule(_ schedule: ExperienceSchedule) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    func experienceWithNumOfLikes(_ numOfLikes: Int?) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    func experienceWithNumOfShares(_ numOfShares: Int?) -> Experience {
        return Experience(id: id,
                          title: title,
                          text: text,
                          images: images,
                          type: type,
                          isVirtual: isVirtual,
                          isPrivate: isPrivate,
                          tier: tier,
                          creator: creator,
                          createdAt: createdAt,
                          expiresAt: expiresAt,
                          radius: radius,
                          schedule: schedule,
                          destination: destination,
                          destinationName: destinationName,
                          destinationAddress: destinationAddress,
                          anywhere: anywhere,
                          neighbourhood: neighbourhood,
                          city: city,
                          state: state,
                          numOfLikes: numOfLikes,
                          numOfShares: numOfShares,
                          posts: posts,
                          history: history,
                          tips: tips)
    }
    
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Experience, rhs: Experience) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.text == rhs.text else { return false }
        guard lhs.images == rhs.images else { return false }
        guard (lhs.posts?.count ?? 0) == (rhs.posts?.count ?? 0) else { return false }
        
        return true
    }
    
    // Helpers
    
    func isClaimable() -> Bool {
        return posts == nil || posts?.isEmpty == true
    }
    
    func isActive() -> Bool {
        
        // is there an active post
        if activePost() != nil {
            return true
        }
        
        // is the schedule active
        if let schedule = schedule {
            return schedule.isActive()
        }
        
        return true
    }
    
    func isNear() -> Bool {
        if let location = destination,
            let myLocation = LocationService.shared.currentLocation,
            myLocation.distance(from: location.location()) > ConfigService.shared.experienceSearchRadius {
            return false
        }
        if let hood = neighbourhood, !hood.isEmpty,
            !LocationService.shared.neighbourhood.isEmpty,
            hood != LocationService.shared.neighbourhood {
            return false
        }
        if let city = city, !city.isEmpty,
            !LocationService.shared.city.isEmpty,
            city != LocationService.shared.city {
            return false
        }
        if let state = state, !state.isEmpty,
            !LocationService.shared.state.isEmpty,
            state != LocationService.shared.state {
            return false
        }
        return true
    }
    
    func short() -> ShortExperience {
        return ShortExperience(
            id: id,
            title: title,
            text: text,
            images: images,
            type: type,
            creator: creator.short(),
            isVirtual: isVirtual,
            isPrivate: isPrivate,
            tier: tier)
    }
    
    func post(from creatorId: String) -> ExperiencePost? {
        return posts?.first(where: { $0.creator.id == creatorId })
    }
    
    func myPost() -> ExperiencePost? {
        return post(from: ProfileService.shared.profile?.id ?? "--")
    }
    
    func request(from creatorId: String) -> ExperienceRequest? {
        for post in posts ?? [] {
            for request in post.requests ?? [] {
                if request.creator.id == creatorId {
                    return request
                }
            }
            
        }
        return nil
    }
    
    func myRequest() -> ExperienceRequest? {
        return request(from: ProfileService.shared.profile?.id ?? "--")
    }
    
    func post(for requestId: String) -> ExperiencePost? {
        for post in posts ?? [] {
            for request in post.requests ?? [] {
                if request.id == requestId {
                    return post
                }
            }
        }
        return nil
    }
    
    func activePosts() -> [ExperiencePost] {
        let now = Date()
        return posts?.filter { $0.isActive(now) && $0.isNear() } ?? []
    }
    
    func activePost() -> ExperiencePost? {
        let now = Date()
        return posts?.first { $0.isActive(now) && $0.isNear() }
    }
    
    func activeGroup() -> [ShortUser] {
        var users: [ShortUser] = []
        if let post = activePost() {
            users.append(post.creator.short())
            for request in post.requests ?? [] {
                if request.accepted == true {
                    users.append(request.creator)
                }
            }
        } else {
            users.append(creator.short())
        }
        return users
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                json.removeValue(forKey: "posts")
                json.removeValue(forKey: "history")
                json.removeValue(forKey: "tips")
                json.removeValue(forKey: "destination")
                
                json.removeValue(forKey: "schedule")
                json["schedule"] = schedule?.json
                
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> Experience? {
        
        let destination: GeoPoint? = json["destination"] as? GeoPoint
        let schedule: [String: Any]? = json["schedule"] as? [String: Any]
        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "destination")
        rectifiedJson.removeValue(forKey: "schedule")
        rectifiedJson.removeValue(forKey: "postLocations")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            var experience = try? JSONDecoder().decode(Experience.self, from: jsonData) {
            
            if let destination = destination {
                experience = experience.experienceWithDestination(destination)
            }
            
            if let schedule = schedule, let scheduleObj = ExperienceSchedule.fromJson(schedule) {
                experience = experience.experienceWithSchedule(scheduleObj)
            }
            
            return experience.experienceWithImages(experience.images.sorted(by: { (lhs, rhs) -> Bool in
                lhs.order < rhs.order
            }))
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Experience? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Experience.fromJson(json)
        }
        return nil
    }
}

extension Experience: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? Experience {
            return self == other
        }
        return false
    }
}
