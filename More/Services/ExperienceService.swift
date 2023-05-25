//
//  ExperienceService.swift
//  More
//
//  Created by Luko Gjenero on 04/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase
import MapKit
import Geofirestore
import GeoFire


class ExperienceService {

    struct Notifications {
        static let ExperiencesStartLoad = NSNotification.Name(rawValue: "com.more.experience.startListLoad")
        static let ExperiencesLoaded = NSNotification.Name(rawValue: "com.more.experience.listLoaded")
        static let ExperienceEnteredRegion = NSNotification.Name(rawValue: "com.more.experience.entered")
        static let ExperienceExitedRegion = NSNotification.Name(rawValue: "com.more.experience.exited")
    }
    
    static let shared = ExperienceService()
    
    private var geoFireRef: CollectionReference
    private var geoFire: GeoFirestore
    private var query: GFSRegionQuery?
    
    private struct TrackingPlaces {
        var anywhereTracker: ListenerRegistration?
        var neighbourhood: String = ""
        var neighbourhoodTracker: ListenerRegistration?
        var city: String = ""
        var cityTracker: ListenerRegistration?
        var state: String = ""
        var stateTracker: ListenerRegistration?
    }
    
    private var trackedByPlace = TrackingPlaces()
        
    init() {
        geoFireRef =  Firestore.firestore().collection("experienceLocations")
        geoFire = GeoFirestore(collectionRef: geoFireRef)
        
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(configLoaded), name: ConfigService.Notifications.ConfigLoaded, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startTracking), name: ProfileService.Notifications.ProfileLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopTracking), name: ProfileService.Notifications.ProfileLogout, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: LocationService.Notifications.LocationUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationDecription), name: LocationService.Notifications.LocationDescription, object: nil)
        
        loadSeenExperiences()
        toForeground()
    }
    
    @objc private func toForeground() {
        loadExperiencesQueueAroundMeIfNecessary()
    }
    
    @objc private func toBackground() {
        // nop
    }
    
    @objc private func startTracking() {
        loadExperiencesQueueAroundMeIfNecessary()
    }
    
    @objc private func stopTracking() {
        stopTrackingAroundMe()
//        stopTrackingByPlaces()
    }
    
    @objc private func locationUpdated() {
        // loadExperiencesQueueAroundMeIfNecessary()
    }
    
    @objc private func locationDecription() {
        loadExperiencesQueueAroundMeIfNecessary()
    }
    
    @objc private func configLoaded() {
        loadExperiencesQueueAroundMeIfNecessary()
    }
    
    // MARK: - tracking around me
    
    private var queryHandles: [GFSQueryHandle] = []
    
    @objc private func stopTrackingAroundMe() {
        for handle in queryHandles {
            query?.removeObserver(withHandle: handle)
        }
        queryHandles.removeAll()
        query = nil
    }
    
    // MARK: - load queue
    
    private struct ExperienceQueueItem {
        let experienceId: String
        var experience: Experience? = nil
        var loaded: Bool = false
    }
    
    struct ExperienceQueueType: OptionSet {
        let rawValue: Int
        
        static let location = ExperienceQueueType(rawValue: 1)
        static let anywhere = ExperienceQueueType(rawValue: 1 << 1)
        static let neighbourhood = ExperienceQueueType(rawValue: 1 << 2)
        static let city = ExperienceQueueType(rawValue: 1 << 3)
        static let state = ExperienceQueueType(rawValue: 1 << 4)
        
        static let all: ExperienceQueueType = [.location, .anywhere, .neighbourhood, .city, .state]
    }
    
    private var queueId: TimeInterval = 0
    private var queueExperiences: [ExperienceQueueItem] = []
    private var queueLoaded: ExperienceQueueType = []
   
    private var seenExperiences: [String] = []
    private var experiences: [Experience] = []
    
    func getExperiences() -> [Experience] {
        return experiences
    }
    
    private struct ExperienceQueueLoad {
        var timestamp: TimeInterval? = nil
        var location: CLLocation? = nil
        var neighbourhood: String = ""
        var city: String = ""
        var state: String = ""
    }
    
    private var queueLoad: ExperienceQueueLoad = ExperienceQueueLoad()
    
    private func loadExperiencesQueueAroundMeIfNecessary() {
        guard let location = LocationService.shared.currentLocation else { return }
        
        var load = false
        
        // do not reload if the location has not moved more than X meters
        if let queueLocation = queueLoad.location {
            if queueLocation.distance(from: location) > ConfigService.shared.experienceRefreshLocation {
                load = true
            }
        } else {
            load = true
        }
        
        // do not load same neighbourhoods
        if queueLoad.neighbourhood != LocationService.shared.neighbourhood ||
            queueLoad.city != LocationService.shared.city ||
            queueLoad.state != LocationService.shared.state {
            load = true
        }
        
        // do not load unless time limit has passed
        let now = Date().timeIntervalSince1970
        if let timestamp = queueLoad.timestamp, now - timestamp > ConfigService.shared.experienceRefreshTime {
            load = true
        }
        
        guard load else { return }
        loadExperiencesQueueAroundMe()
    }
    
    private func loadExperiencesQueueAroundMe() {
        
        NotificationCenter.default.post(name: Notifications.ExperiencesStartLoad, object: self, userInfo: nil)
        
        loadExperiencesQueueAroundMe { [weak self] (experiences) in
            guard let sself = self else { return }
            
            var limited: [Experience] = []
            if ConfigService.shared.experienceLimit > 0 {
                for experience in experiences {
                    if experience.activePost() != nil {
                        limited.append(experience)
                    } else if !sself.seenExperiences.contains(experience.id) {
                        sself.seenExperiences.append(experience.id)
                        limited.append(experience)
                    }
                    if limited.count >= ConfigService.shared.experienceLimit {
                        break
                    }
                }
                
                if limited.count < ConfigService.shared.experienceLimit && experiences.count >= limited.count {
                    sself.seenExperiences = []
                    for experience in experiences {
                        if !limited.contains(experience) {
                            limited.append(experience)
                        }
                        if limited.count >= ConfigService.shared.experienceLimit {
                            break
                        }
                    }
                    for experience in limited {
                        if experience.activePost() == nil {
                            sself.seenExperiences.append(experience.id)
                        }
                    }
                }
            } else {
                sself.seenExperiences = []
                limited = experiences
            }
            
            sself.storeSeenExperiences()
            
            for experience in limited {
                ExperienceTrackingService.shared.track(experienceId: experience.id)
                Analytics.logEvent("ExperienceFound", parameters: ["experienceId": experience.id, "title": experience.title , "text": experience.text])
                if let post = experience.activePost() {
                    Analytics.logEvent("ExperiencePostFound", parameters: ["experienceId": experience.id, "postId": post.id])
                }
            }
            
            sself.experiences = limited
            NotificationCenter.default.post(name: Notifications.ExperiencesLoaded, object: self, userInfo: ["experiences": limited])
        }
    }
    
    private func loadExperiencesQueueAroundMe(_ completion: ((_ experiences: [Experience])->())?) {
        guard ProfileService.shared.profile?.getId() != nil else { return }
        guard let location = LocationService.shared.currentLocation else { return }
        
        // stop all queries
        for handle in queryHandles {
            query?.removeObserver(withHandle: handle)
        }
        queryHandles.removeAll()
        
        queueLoad.location = location
        queueLoad.timestamp = Date().timeIntervalSince1970
        
        let radius = ProfileService.shared.profile?.isAdmin == true ? 1000 : ConfigService.shared.experienceSearchRadius / 1000.0
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius * 4, longitudinalMeters: radius * 4)
        let query = geoFire.query(inRegion: region)
        let queueId = Date().timeIntervalSince1970
        
        self.query = query
        self.queueId = queueId
        queueExperiences = []
        queueLoaded = []
        
        var handle = query.observe(.documentEntered, with: { [weak self] (experienceId, _) in
            guard let experienceId = experienceId else { return }
            self?.loadExperienceForQueue(experienceId, queueId, completion)
        })
        queryHandles.append(handle)
        handle = query.observeReady { [weak self] in
            // queue loaded
            self?.queueLoaded.insert(.location)
            
            // stop all queries
            for handle in self?.queryHandles ?? [] {
                self?.query?.removeObserver(withHandle: handle)
            }
            self?.queryHandles.removeAll()
            
            // check queue loaded
            self?.checkIfQueueLoaded(queueId, completion)
        }
        queryHandles.append(handle)
        
        // anywhere
        loadExperiencesForQueue("anywhere", true, .anywhere, queueId, completion)

        // neighbourhood
        let neighbourhood = LocationService.shared.neighbourhood
        if !neighbourhood.isEmpty {
            queueLoad.neighbourhood = neighbourhood
            loadExperiencesForQueue("neighbourhood", Helper.sanitize(neighbourhood), .neighbourhood, queueId, completion)
        } else {
            queueLoaded.insert(.neighbourhood)
            queueLoad.neighbourhood = ""
        }
        
        // city
        let city = LocationService.shared.city
        if !city.isEmpty {
            queueLoad.city = city
            loadExperiencesForQueue("city", Helper.sanitize(city), .city, queueId, completion)
        } else {
            queueLoaded.insert(.city)
            queueLoad.city = ""
        }
        
        // state
        let state = LocationService.shared.state
        if !state.isEmpty {
            queueLoad.state = state
            loadExperiencesForQueue("state", Helper.sanitize(state), .state, queueId, completion)
        } else {
            queueLoaded.insert(.state)
            queueLoad.state = ""
        }
    }
    
    private func checkIfQueueLoaded(_ queueId: TimeInterval, _ completion: ((_ experiences: [Experience])->())?) {
        guard self.queueId == queueId else { return }
        guard queueLoaded.contains(.all) else { return }
        guard let myLocation = LocationService.shared.currentLocation else { return }
        
        var experiences: [Experience] = []
        for item in queueExperiences {
            if !item.loaded {
                return
            }
            if let experience = item.experience {
                experiences.append(experience)
            }
        }
        
        experiences.sort { (lhs, rhs) -> Bool in
            let lhsPost = lhs.activePost()
            let rhsPost = rhs.activePost()
            
            // sort by post activation first
            if let lhsPost = lhsPost {
                if let rhsPost = rhsPost {
                    return lhsPost.expiresAt < rhsPost.expiresAt
                } else {
                    return true
                }
            } else if rhsPost != nil {
                return false
            }
            
            // sort by location
            if let lhsDestination = lhs.destination {
                if let rhsDestination = rhs.destination {
                    return myLocation.distance(from: lhsDestination.location()) < myLocation.distance(from: rhsDestination.location())
                }
                return true
            }
            if rhs.destination != nil {
                return false
            }
            
            // sort by neighbourhood
            if lhs.neighbourhood != nil {
                if rhs.neighbourhood != nil {
                    return lhs.createdAt > rhs.createdAt
                }
                return true
            }
            if rhs.neighbourhood != nil {
                return false
            }
            
            // sort by city
            if lhs.city != nil {
                if rhs.city != nil {
                    return lhs.createdAt > rhs.createdAt
                }
                return true
            }
            if rhs.city != nil {
                return false
            }
            
            // sort by state
            if lhs.state != nil {
                if rhs.state != nil {
                    return lhs.createdAt > rhs.createdAt
                }
                return true
            }
            if rhs.state != nil {
                return false
            }
            
            // sort by "freshness" - right now by time of creation
            return lhs.createdAt > rhs.createdAt
        }
        
        completion?(experiences)
    }
    
    private func getExperienceQueueItem(_ experienceId: String) -> ExperienceQueueItem? {
        return queueExperiences.first(where: { $0.experienceId == experienceId })
    }
    
    private let seenExperiencesKey = "com.more.experience.seen"
    
    private func loadSeenExperiences() {
        if let data = UserDefaults.standard.value(forKey: seenExperiencesKey) as? Data,
            let seen = try? PropertyListDecoder().decode([String].self, from: data) {
            seenExperiences = seen
        }
    }
    
    private func storeSeenExperiences() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(seenExperiences), forKey: seenExperiencesKey)
    }
    
    // MARK: - helpers
    
    private func loadExperienceForQueue(_ experienceId: String, _ queueId: TimeInterval, _ completion: ((_ experiences: [Experience])->())?) {
        guard self.queueId == queueId else { return }
        guard getExperienceQueueItem(experienceId) == nil else { return }

        queueExperiences.append(ExperienceQueueItem(experienceId: experienceId))
        loadExperience(experienceId: experienceId, completion: { [weak self] (experience, errorMsg) in
            guard self?.queueId == queueId else { return }
            if let idx = self?.queueExperiences.firstIndex(where: { $0.experienceId == experienceId }) {
                if let experience = experience,
                ExperienceService.shouldShowExperience(experience),
                    experience.isActive() {
                    self?.queueExperiences[idx].experience = experience
                }
                self?.queueExperiences[idx].loaded = true
                self?.checkIfQueueLoaded(queueId, completion)
            }
        })
    }
    
    private class func shouldShowExperience(_ experience: Experience) -> Bool {
        
        // is active
        let isActive = experience.isActive()
        
        // is admin
        let isAdmin = ProfileService.shared.profile?.isAdmin == true
        
        // non private or activated nearby
        let privateOk = !(experience.isPrivate == true) || experience.activePost()?.isNear() == true
        
        // is near or activated nearby
        let nearby = experience.isNear() || experience.activePost()?.isNear() == true
        
        return isActive && (isAdmin || (privateOk && nearby))
    }
    
    private func loadExperiencesForQueue(_ key: String, _ value: Any, _ type: ExperienceQueueType, _ queueId: TimeInterval, _ completion: ((_ experiences: [Experience])->())?) {
        guard self.queueId == queueId else { return }
        
        Firestore.firestore().collection(Paths.experiences)
            .whereField(key, isEqualTo: value)
            .getDocuments(completion: { [weak self] (snapshot, error) in
                if let snapshot = snapshot {
                    snapshot.documents.forEach { doc in
                        guard let experience = Experience.fromSnapshot(doc) else { return }
                        if experience.isActive() {
                            self?.loadExperienceForQueue(experience.id, queueId, completion)
                        }
                    }
                }
                // queue loaded
                self?.queueLoaded.insert(type)
                self?.checkIfQueueLoaded(queueId, completion)
            })
    }
    
    // MARK: - api
    
    /// Create Experience
    /// - Parameter experience: experience to create
    /// - Parameter complete: completion callback
    func createExperience(from experience: Experience, complete:((_ id: String?, _ errorMsg: String?)->())?) {
        
        guard let _ = ProfileService.shared.profile?.getId(),
            let data = experience.json else {
                complete?(nil, "Not logged in")
                return
        }
        
        let newExperience = Firestore.firestore().collection(Paths.experiences).document()
        newExperience.setData(data) { [weak self] (error) in
            if let error = error {
                complete?(nil, error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                return
            }
            
            let experienceId = newExperience.documentID
            
            if let point = experience.destination {
                self?.updateExperienceDestination(experienceId: experienceId, destination: point)
            }
  
            Analytics.logEvent("ExperienceCreated", parameters: ["experienceId": experienceId, "title": experience.title , "text": experience.text])

            complete?(experienceId, nil)
        }
    }
    
    func updateExperienceDestination(experienceId: String, destination: GeoPoint) {
        Firestore.firestore().document(Paths.experience(experienceId))
            .updateData(["destination": destination])
        geoFire.setLocation(geopoint: destination, forDocumentWithID: experienceId)
    }
    
    func createExperiencePost(for experience: Experience, post: ExperiencePost, complete:((_ id: String?, _ error: Error?)->())?) {
        
        guard let myId = ProfileService.shared.profile?.getId(), !experience.id.isEmpty else {
            complete?(nil, MoreError.notLoggedIn())
            return
        }
        
        // check if there is a post nearby
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            
            let path = Firestore.firestore().document(Paths.experience(experience.id))
            let experienceDoc: DocumentSnapshot
            do {
                try experienceDoc = transaction.getDocument(path)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var postLocations: [String: [Double]] = [:]
            if let myLocation = LocationService.shared.currentLocation,
                let locations = experienceDoc.data()?["postLocations"] as? [String: [Double]],
                !locations.isEmpty {
                
                var create = true
                for (_, coords) in locations where coords.count >= 2 {
                    let location = CLLocation(latitude: coords[0], longitude: coords[1])
                    if location.distance(from: myLocation) < ConfigService.shared.experienceSearchRadius {
                        create = false
                        break
                    }
                }
                
                if !create {
                    errorPointer?.pointee = MoreError.postCreated()
                    return nil
                }
                
                postLocations = locations
            }
            
            if let myLocation = LocationService.shared.currentLocation {
                postLocations[myId] = [myLocation.coordinate.latitude, myLocation.coordinate.longitude]
            }

            transaction.updateData(["postLocations": postLocations], forDocument: path)
            return nil
        },
        completion: { [weak self] (postId, error) in
            if let error = error {
                complete?(nil, error)
                Crashlytics.crashlytics().record(error: error)
            } else {
                self?.internalCreateExperiencePost(for: experience, post: post, complete: complete)
            }
        })
    }
        
    private func internalCreateExperiencePost(for experience: Experience, post: ExperiencePost, complete:((_ id: String?, _ error: Error?)->())?) {
        
        guard let _ = ProfileService.shared.profile?.getId(),
            let data = post.json else {
                complete?(nil, MoreError.notLoggedIn())
                return
        }
        
        let newPost = Firestore.firestore().collection(Paths.posts(experience.id)).document()
        newPost.setData(data) { [weak self] (error) in
            if let error = error {
                complete?(nil, error)
                Crashlytics.crashlytics().record(error: error)
                return
            }
            
            let postId = newPost.documentID
            
            Analytics.logEvent("ExperiencePostCreated", parameters: ["experienceId": experience.id, "postId": postId])
            
            if let point = post.location {
                self?.updateExperiencePostLocation(experienceId: experience.id, postId: postId, location: point)
            }
            
            complete?(postId, nil)
        }
    }
    
    func updateExperiencePostLocation(experienceId: String, postId: String, location: GeoPoint) {
        Firestore.firestore().document(Paths.post(experienceId, postId))
            .updateData(["location": location])
    }
    
    func updateExperiencePostMeetingLocation(experienceId: String, postId: String, location: GeoPoint, name: String?, address: String?, type: MeetType?, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        var update: [AnyHashable: Any] = [:]
        update["meeting"] = location
        if let name = name {
            update["meetingName"] = name
        }
        if let address = address {
            update["meetingAddress"] = address
        }
        if let type = type {
            update["meetingType"] = type.rawValue
        } else {
            update["meetingType"] = FieldValue.delete()
        }
        
        Firestore.firestore().document(Paths.post(experienceId, postId))
            .updateData(update) { error in
                if let error = error {
                    complete?(false, error.localizedDescription)
                    return
                }
                complete?(true, nil)
        }
    }
    
    func createExperienceRequest(for experience: Experience, post: ExperiencePost, request: ExperienceRequest, complete:((_ id: String?, _ errorMsg: String?)->())?) {
        
        guard let me = ProfileService.shared.profile else {
            complete?(nil, "Not logged in")
            return
        }
        
        // check if I already requested
        Firestore.firestore().collection(Paths.requests(experience.id, post.id))
            .whereField("creator.id", isEqualTo: me.id)
            .getDocuments { [weak self] (snapshot, error) in
                if snapshot?.isEmpty == true {
                    self?.internalCreateExperienceRequest(for: experience, post: post, request: request, complete: complete)
                    return
                }
                
                if let document = snapshot?.documents.first {
                    if experience.isVirtual == true {
                        self?.createVirtualExperienceRequest(for: experience, post: post, request: request.requestWithId(document.documentID), complete: complete)
                        return
                    }
                    return
                }
                
                complete?(nil, error?.localizedDescription)
            }
    }
    
    private func internalCreateExperienceRequest(for experience: Experience, post: ExperiencePost, request: ExperienceRequest, complete:((_ id: String?, _ errorMsg: String?)->())?) {
        
        guard let data = request.json else {
            complete?(nil, "Data issue")
            return
        }
        
        let newRequest = Firestore.firestore().collection(Paths.requests(experience.id, post.id)).document()
        newRequest.setData(data) { (error) in
            if let error = error {
                complete?(nil, error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                return
            }
            
            let requestId = newRequest.documentID
            
            Analytics.logEvent("ExperienceRequestCreated", parameters: ["experienceId": experience.id, "postId": post.id, "requestId": requestId])
            
            if experience.isVirtual == true {
                ExperienceService.shared.createVirtualExperienceRequest(for: experience, post: post, request: request.requestWithId(requestId), complete: complete)
                return
            }
            
            complete?(requestId, nil)
        }
    }
    
    private func createVirtualExperienceRequest(for experience: Experience, post: ExperiencePost, request: ExperienceRequest, complete:((_ id: String?, _ errorMsg: String?)->())?) {
        
        guard let me = ProfileService.shared.profile else {
                complete?(nil, "Not logged in")
                return
        }
        
        // chat exists -> just need to accept
        if let chat = post.chat {
            ExperienceService.shared.acceptRequest(experienceId: experience.id, postId: post.id, requestId: request.id) { (success, errorMsg) in
                complete?(success ? chat.id : nil, errorMsg)
            }
            return
        }
        
        // need to create the chat
        let chat = Chat(
            id: "-",
            createdAt: Date(),
            members: [post.creator.short()],
            type: .group,
            messages: nil,
            typing: [],
            creator: post.creator.short())
        
        ChatService.shared.createChat(chat: chat) { (chatId, errorMsg) in
            if let chatId = chatId {
                
                let updatedChat = chat.chatWithId(chatId).short()
                
                // update post chat
                Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
                    
                    let path = Firestore.firestore().document(Paths.post(experience.id, post.id))
                    let postDoc: DocumentSnapshot
                    do {
                        try postDoc = transaction.getDocument(path)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return false
                    }
                    
                    if postDoc.data()?["chat"] == nil {
                        if let data = updatedChat.json {
                            transaction.updateData(["chat": data], forDocument: path)
                        }
                    }
                    return true
                },
                completion: { (success, error) in
                    if let success = success as? Bool, success {
                        
                        // announce message
                        let msgId = "\(me.id.hashValue)-\(Date().hashValue)"
                        let additional = Message.additionalVirtualTimeData(id: experience.id, title: experience.title)
                        let additionalData = Message.additionalData(from: additional)
                        let msg = Message(id: msgId, createdAt: Date(), sender: post.creator.short(), type: .created, text: "\(post.creator.name) created the group", additionalData: additionalData, deliveredAt: nil, readAt: nil)
                        ChatService.shared.sendMessage(chatId: chatId, message: msg)
                        
                        // accept request
                        ExperienceService.shared.acceptRequest(experienceId: experience.id, postId: post.id, requestId: request.id) { (success, errorMsg) in
                            complete?(success ? chatId : nil, errorMsg)
                        }
                    } else {
                        ChatService.shared.deleteChat(chatId: chatId, complete: nil)
                        ExperienceTrackingService.shared.track(experienceId: experience.id, forceRefresh: true)
                        complete?(nil, error?.localizedDescription ?? "Unknown error")
                        if let error = error {
                            Crashlytics.crashlytics().record(error: error)
                        }
                    }
                })
            } else {
                complete?(nil, errorMsg)
            }
        }
    }
    
    func reserveVirtualExperienceRequest(for experience: Experience, post: ExperiencePost, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            
            let path = Firestore.firestore().document(Paths.post(experience.id, post.id))
            let postDoc: DocumentSnapshot
            do {
                try postDoc = transaction.getDocument(path)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var newSpots = 0
            if let spots = postDoc.data()?["spots"] as? Int {
                newSpots = spots + 1
            } else {
                newSpots = 1
            }
            
            if newSpots >= Config.Experience.virtualSpots {
                return false
            } else {
                transaction.updateData(["spots": newSpots], forDocument: path)
                return true
            }
        },
        completion: { (hasSpotsLeft, error) in
            if let hasSpotsLeft = hasSpotsLeft as? Bool {
                complete?(hasSpotsLeft, hasSpotsLeft ? nil : "No more spots")
            } else {
                complete?(false, error?.localizedDescription ?? "Unknown error")
                if let error = error {
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        })
    }
    
    func cancelVirtualExperienceRequestReservation(for experience: Experience, post: ExperiencePost, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        Firestore.firestore().document(Paths.post(experience.id, post.id)).updateData(["spots": FieldValue.increment(Int64(-1))]) { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                return
            }
            complete?(true, nil)
        }
    }
    
    
//    func updateExperienceRequestLocation(experienceId: String, postId: String, requestId: String, location: GeoPoint) {
//        Firestore.firestore()
//            .document(Paths.request(experienceId, postId, requestId))
//            .updateData(["location": location])
//    }
    
    func deleteExperience(experienceId: String, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        Firestore.firestore().document(Paths.experience(experienceId)).delete { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                return
            }
            
            Analytics.logEvent("ExperienceDeleted", parameters: ["experienceId": experienceId])
            
            complete?(true, nil)
        }
    }
    
    func deletePost(experienceId: String, postId: String, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        Firestore.firestore().document(Paths.post(experienceId, postId)).delete { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                return
            }
            
            Analytics.logEvent("ExperiencePostDeleted", parameters: ["experienceId": experienceId, "postId": postId])
            
            complete?(true, nil)
        }
    }
    
    func acceptRequest(experienceId: String, postId: String, requestId: String, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard ProfileService.shared.profile?.getId() != nil else { return }
       
        Firestore.firestore()
            .document(Paths.request(experienceId, postId, requestId))
            .updateData(["accepted": true]) { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                return
            }
            
            Analytics.logEvent("ExperienceRequestAccepted", parameters: ["experienceId": experienceId, "postId": postId, "requestId": requestId])
            
            complete?(true, nil)
        }
    }
    
    func acceptRequests(post: ExperiencePost, users: [ShortUser], complete: (()->())?) {
        var usersBlock = users
        var waitForCalls = false
        for user in users {
            if let request = post.request(from: user.id) {
                waitForCalls = true
                acceptRequest(experienceId: post.experience.id, postId: post.id, requestId: request.id) { (sucess, errorMsg) in
                    usersBlock.removeAll(where: { $0.id == user.id })
                    
                    if usersBlock.isEmpty {
                        complete?()
                    }
                }
            } else {
                usersBlock.removeAll(where: { $0.id == user.id })
            }
        }
        if !waitForCalls {
            complete?()
        }
    }
    
    func cancelRequest(experienceId: String, postId: String, requestId: String, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard ProfileService.shared.profile?.getId() != nil else { return }
       
        Firestore.firestore()
            .document(Paths.request(experienceId, postId, requestId))
            .updateData(["accepted": false]) { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                return
            }
            
            Analytics.logEvent("ExperienceRequestCancelled", parameters: ["experienceId": experienceId, "postId": postId, "requestId": requestId])
            
            complete?(true, nil)
        }
    }
    
    
    func updatePostChat(experienceId: String, postId: String, chat: Chat, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard ProfileService.shared.profile?.getId() != nil else { return }
        guard let data = chat.short().json else { return }
        
        Firestore.firestore()
            .document(Paths.post(experienceId, postId))
            .updateData(["chat": data]) { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                return
            }
            complete?(true, nil)
        }
    }
    
    func startPost(experienceId: String, postId: String, chat: Chat, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard ProfileService.shared.profile?.getId() != nil else { return }
        
        updatePostChat(experienceId: experienceId, postId: postId, chat: chat) { (success, error) in
            if success {
                Firestore.firestore()
                    .document(Paths.post(experienceId, postId))
                    .updateData(["started": true]) { (error) in
                    if let error = error {
                        complete?(false, error.localizedDescription)
                        return
                    }
                    complete?(true, nil)
                }
            } else {
                complete?(false, error)
            }
        }
    }
    
    // MARK: - likes
    
    private var myLikedExperiences: [String: Bool] = [:]
    
    func likeExperience(experience: Experience, completion: ((_ success: Bool, _ errorMsg: String?)->())?) {
        
        guard let me = ProfileService.shared.profile?.shortUser else {
                completion?(false, "Not logged in")
                return
        }
        
        myLikedExperiences[experience.id] = true
        
        let like = ExperienceLike(id: "", experience: experience.short(), creator: me, createdAt: Date())
        
        guard let data = like.json else {
                completion?(false, "Data error")
                return
        }
        
        Firestore.firestore().document(Paths.like(experience.id, me.id))
            .setData(data) { (error) in
                if let error = error {
                    completion?(false, error.localizedDescription)
                    return
                }
                    
                Analytics.logEvent("ExperienceLiked", parameters: ["experienceId": experience.id, "userId": me.id])
                
                completion?(true, nil)
            }
    }
    
    func dislikeExperience(experience: Experience, completion: ((_ success: Bool, _ errorMsg: String?)->())?) {
        
        guard let me = ProfileService.shared.profile?.shortUser else {
                completion?(false, "Not logged in")
                return
        }
        
        myLikedExperiences[experience.id] = false
        
        Firestore.firestore().document(Paths.like(experience.id, me.id))
            .delete { (error) in
                if let error = error {
                    completion?(false, error.localizedDescription)
                    return
                }
                    
                Analytics.logEvent("ExperienceLikeRemoved", parameters: ["experienceId": experience.id, "userId": me.id])
                
                completion?(true, nil)
            }
    }
    
    func haveLikedExperience(experienceId: String, completion: ((_ liked: Bool?, _ errorMsg: String?)->())?) {
        
        guard let me = ProfileService.shared.profile?.shortUser else {
                completion?(false, "Not logged in")
                return
        }
        
        if let liked = myLikedExperiences[experienceId] {
            completion?(liked, nil)
            return
        }
        
        Firestore.firestore().document(Paths.like(experienceId, me.id))
            .getDocument(completion: { [weak self] (snapshot, error) in
                if let snapshot = snapshot, snapshot.exists {
                    self?.myLikedExperiences[experienceId] = true
                    completion?(true, nil)
                } else if let error = error {
                    completion?(nil, error.localizedDescription)
                } else {
                    self?.myLikedExperiences[experienceId] = false
                    completion?(false, "Like not found")
                }
            })
    }
    
    func loadExperienceLikes(experienceId: String, limit: Int, startAfter: DocumentSnapshot? = nil, completion: ((_ likes: [ExperienceLike]?, _ last: DocumentSnapshot?, _ errorMsg: String?)->())?) {
        
        var query = Firestore.firestore().collection(Paths.likes(experienceId))
            .order(by: "createdAt", descending: true)
            
        if let startAfter = startAfter {
            query = query.start(afterDocument: startAfter)
        }
                
        query.limit(to: limit)
            .getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    var likes: [ExperienceLike] = []
                    for child in snapshot.documents {
                        if let like = ExperienceLike.fromSnapshot(child) {
                            likes.append(like)
                        }
                    }
                    completion?(likes, snapshot.documents.last, nil)
                } else if let error = error {
                    completion?(nil, nil, error.localizedDescription)
                } else {
                    completion?(nil, nil, "Likes not found")
                }
            }
    }
    
    // MARK: - shares
    
    func shareExperience(experience: Experience, completion: ((_ success: Bool, _ errorMsg: String?)->())?) {
        
        guard let me = ProfileService.shared.profile?.shortUser else {
                completion?(false, "Not logged in")
                return
        }
        
        let update = ["numOfShares": FieldValue.increment(Int64(1))]
        Firestore.firestore().document(Paths.experience(experience.id))
            .updateData(update) { (error) in
                    if let error = error {
                        completion?(false, error.localizedDescription)
                        return
                    }
                    completion?(true, nil)
            }
        
        Analytics.logEvent("ExperienceShared", parameters: ["experienceId": experience.id, "userId": me.id])
    }
    
    // MARK: - tips
    
    func addExperienceTip(experienceId: String, tip: ExperienceTip, completion: ((_ tip: ExperienceTip?, _ errorMsg: String?)->())?) {
        
        guard let _ = ProfileService.shared.profile?.getId(),
            let data = tip.json else {
                completion?(nil, "Not logged in")
                return
        }
        
        let newTip = Firestore.firestore().collection(Paths.tips(experienceId)).document()
        newTip.setData(data) { (error) in
            if let error = error {
                completion?(nil, error.localizedDescription)
                return
            }
            
            let tipId = newTip.documentID
            
            Analytics.logEvent("ExperienceTipCreated", parameters: ["experienceId": experienceId, "tipId": tipId , "text": tip.text])
            
            completion?(tip.tipWithId(tipId), nil)
        }
    }
    
    func upvoteExperienceTip(experienceId: String, tipId: String, completion: ((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let myId = ProfileService.shared.profile?.getId() else {
            completion?(false, "Not logged in")
            return
        }
        
        let update = ["upvote": FieldValue.arrayUnion([myId])]
        Firestore.firestore().document(Paths.tip(experienceId, tipId))
            .updateData(update) { (error) in
                if let error = error {
                    completion?(false, error.localizedDescription)
                    return
                }
                completion?(true, nil)
        }
    }
    
    func downvoteExperienceTip(experienceId: String, tipId: String, completion: ((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let myId = ProfileService.shared.profile?.getId() else {
            completion?(false, "Not logged in")
            return
        }
        
        let update = ["downvote": FieldValue.arrayUnion([myId])]
        Firestore.firestore().document(Paths.tip(experienceId, tipId))
            .updateData(update) { (error) in
                if let error = error {
                    completion?(false, error.localizedDescription)
                    return
                }
                completion?(true, nil)
        }
    }
    
    // MARK: - load experience
    
    func loadExperience(experienceId: String, completion: ((_ experience: Experience?, _ errorMsg: String?)->())?) {
        
        Firestore.firestore()
            .document(Paths.experience(experienceId))
            .getDocument { [weak self] (snapshot, error) in
                if let snapshot = snapshot, snapshot.exists,
                    let experience = Experience.fromSnapshot(snapshot) {
                    self?.loadExperienceTips(experience: experience, completion: { [weak self] (experience, errorMsg) in
                        if let experience = experience {
                            self?.loadExperiencePosts(experience: experience, completion: completion)
                        } else {
                            completion?(nil, errorMsg)
                        }
                    })
                } else if let error = error {
                    completion?(nil, error.localizedDescription)
                } else {
                    completion?(nil, "Experience not found")
                }
            }
    }
    
    // MARK: - load posts
    
    private func loadExperiencePosts(experience: Experience, completion: ((_ experience: Experience?, _ errorMsg: String?)->())?) {
        
        Firestore.firestore()
            .collection(Paths.posts(experience.id))
            .getDocuments { [weak self] (snapshot, error) in
                if let snapshot = snapshot {
                    var posts: [ExperiencePost] = []
                    for child in snapshot.documents {
                        if let post = ExperiencePost.fromSnapshot(child) {
                            posts.append(post)
                        }
                    }
                    
                    let updated = experience.experienceWithPosts(posts)
                    self?.loadExperienceRequests(experience: updated, completion: completion)
                } else if let error = error {
                    completion?(experience, error.localizedDescription)
                } else {
                    completion?(experience, "Posts not found")
                }
            }
    }
    
    // MARK: - load requests
    
    private func loadExperienceRequests(experience: Experience, buffer: [ExperiencePost]? = nil, completion: ((_ experience: Experience?, _ errorMsg: String?)->())?) {
        
        var updatedBuffer: [ExperiencePost]? = buffer ?? experience.posts
        
        guard let post = updatedBuffer?.first else {
            completion?(experience, nil)
            return
        }
        updatedBuffer?.removeFirst()
        
        Firestore.firestore()
            .collection(Paths.requests(experience.id, post.id))
            .getDocuments { [weak self] (snapshot, error) in
                if let snapshot = snapshot {
                    var requests: [ExperienceRequest] = []
                    for child in snapshot.documents {
                        if let request = ExperienceRequest.fromSnapshot(child) {
                            requests.append(request)
                        }
                    }
                    
                    // update the post requests
                    let updatedPost = post.postWithRequests(requests)
                    var updatedPosts = experience.posts ?? []
                    if let idx = updatedPosts.firstIndex(of: post) {
                        updatedPosts.remove(at: idx)
                        updatedPosts.insert(updatedPost, at: idx)
                    } else {
                        updatedPosts.append(post)
                    }
                    
                    let updated = experience.experienceWithPosts(updatedPosts)
                    self?.loadExperienceRequests(experience: updated, buffer: updatedBuffer, completion: completion)
                } else {
                    self?.loadExperienceRequests(experience: experience, buffer: updatedBuffer, completion: completion)
                }
            }
    }
    
    // MARK: - load tips
    
    private func loadExperienceTips(experience: Experience, completion: ((_ experience: Experience?, _ errorMsg: String?)->())?) {
        
        Firestore.firestore()
            .collection(Paths.tips(experience.id))
            .getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    var tips: [ExperienceTip] = []
                    for child in snapshot.documents {
                        if let tip = ExperienceTip.fromSnapshot(child) {
                            tips.append(tip)
                        }
                    }
                    
                    let updated = experience.experienceWithTips(tips)
                    completion?(updated, nil)
                } else if let error = error {
                    completion?(experience, error.localizedDescription)
                } else {
                    completion?(experience, "Posts not found")
                }
            }
    }
    
    // MARK: - load history
    
    // TODO: --
    
}


extension ExperienceService {
    class Paths {
        
        class var experiences: String {
            return "experiences"
        }
        
        class func experience(_ experienceId: String) -> String {
            return "\(experiences)/\(experienceId)"
        }
        
        class func posts(_ experienceId: String) -> String {
            return "\(experience(experienceId))/postList"
        }
        
        class func post(_ experienceId: String, _ postId: String) -> String {
            return "\(posts(experienceId))/\(postId)"
        }
        
        class func requests(_ experienceId: String, _ postId: String) -> String {
            return "\(post(experienceId, postId))/requestList"
        }
        
        class func request(_ experienceId: String, _ postId: String, _ requestId: String) -> String {
            return "\(requests(experienceId, postId))/\(requestId)"
        }
        
        class func tips(_ experienceId: String) -> String {
            return "\(experience(experienceId))/tipList"
        }
        
        class func tip(_ experienceId: String, _ tipId: String) -> String {
            return "\(tips(experienceId))/\(tipId)"
        }
        
        class func likes(_ experienceId: String) -> String {
            return "\(experience(experienceId))/likeList"
        }
        
        class func like(_ experienceId: String, _ userId: String) -> String {
            return "\(likes(experienceId))/\(userId)"
        }
        
        class func times(_ experienceId: String) -> String {
            return "\(experience(experienceId))/timeList"
        }
        
        class func time(_ experienceId: String, _ timeId: String) -> String {
            return "\(times(experienceId))/\(timeId)"
        }
    }
}

// MARK: - helpers

extension ExperienceService {
    class Helper {
        class func sanitize(_ locationName: String) -> String {
            if let idx = locationName.firstIndex(of: Character("/")) {
                return String(locationName.prefix(upTo: idx))
            }
            return locationName
        }
    }
}
