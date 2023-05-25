//
//  TimesService.swift
//  More
//
//  Created by Luko Gjenero on 10/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

class TimesService {
    
    struct Notifications {
        static let TimeLoaded = NSNotification.Name(rawValue: "com.more.experience.times.loaded")
        static let TimeLocation = NSNotification.Name(rawValue: "com.more.experience.times.location")
        static let TimeStateChanged = NSNotification.Name(rawValue: "com.more.experience.times.state")
        static let TimeReview = NSNotification.Name(rawValue: "com.more.experience.times.review")
        static let TimeExpired = NSNotification.Name(rawValue: "com.more.experience.times.expired")
    }
    
    static let shared = TimesService()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate), name: LocationService.Notifications.LocationUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: ProfileService.Notifications.ProfileLogout, object: nil)
        
        load()
        // loadActiveTime()
        loadActiveTimeTracking()
        
        toForeground()
    }
    
    @objc private func toForeground() {
        // restart tracking
        let trackedIds = trackedTimesIds.keys
        trackedTimesIds = [:]
        for timeKey in trackedIds {
            track(experienceId: timeKey.experienceId, timeId: timeKey.timeId)
        }
    }
    
    @objc private func toBackground() {
        // stop tracking
        let trackedIds = trackedTimesIds.keys
        for timeKey in trackedIds {
            if let listeners = trackedTimesIds[timeKey], let unwraped = listeners {
                for listener in unwraped {
                    listener.remove()
                }
            }
        }
    }
    
    @objc private func locationUpdate() {
        
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        guard let coordinates = LocationService.shared.currentLocation?.coordinate else { return }
        
        let now = Date()
        let location = GeoPoint(coordinates: coordinates)
         
        if let current = currentActiveTime {
            
            let experienceId = current.post.experience.id
            let timeId = current.id
            let ref = Firestore.firestore().document("experiences/\(experienceId)/timeList/\(timeId)")
            
            if let meeting = current.meeting {
                let distance = meeting.location().distance(from: location.location())
                ref.updateData(["distances.\(myId)": distance])
            }
                
            if now < currentActiveTimeLocationTracking {
                ref.updateData(["locations.\(myId)": location])
            } else {
                ref.updateData(["locations.\(myId)": FieldValue.delete()])
            }
        }
    }
    
    @objc private func logout() {
        for timeKey in trackedTimesIds.keys {
            removeTracking(experienceId: timeKey.experienceId, timeId: timeKey.timeId)
        }
    }
    
    // MARK: - data
    
    private struct TimeKey: Codable, Hashable {
        let experienceId: String
        let timeId: String
        
        // Hashable
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(experienceId)
            hasher.combine(timeId)
        }
        
        static func == (lhs: TimeKey, rhs: TimeKey) -> Bool {
            return lhs.experienceId == rhs.experienceId && lhs.timeId == rhs.timeId
        }
    }
    
    private let trackedTimesKey = "com.more.times.tracked"
    private var trackedTimesIds: [TimeKey: [ListenerRegistration]?] = [:]
    private var trackedTimes: [TimeKey: ExperienceTime] = [:]
    
    private let currentActiveTimeKey = "com.more.times.active"
    private var currentActiveTime: ExperienceTime? = nil
    
    private let currentActiveTimetrackingKey = "com.more.times.active.tracking"
    private(set) var currentActiveTimeLocationTracking: Date = Date(timeIntervalSince1970: 0)

    private func load() {
        if let data = UserDefaults.standard.value(forKey: trackedTimesKey) as? Data,
            let tracked = try? PropertyListDecoder().decode([TimeKey: Int].self, from: data) {
            self.trackedTimesIds = tracked.mapValues { _ in return nil }
        }
    }
    
    private func loadActiveTime() {
        if let data = UserDefaults.standard.value(forKey:currentActiveTimeKey) as? Data,
            let currentActiveTime = try? PropertyListDecoder().decode(ExperienceTime.self, from: data) {
            if !currentActiveTime.isFinished() {
                self.currentActiveTime = currentActiveTime
            }
        }
    }
    
    private func loadActiveTimeTracking() {
        if let date = UserDefaults.standard.value(forKey:currentActiveTimetrackingKey) as? Date {
            self.currentActiveTimeLocationTracking = date
        }
    }
    
    private func save() {
        let tracked: [TimeKey: Int] = trackedTimesIds.mapValues { _ in return 1 }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(tracked), forKey:trackedTimesKey)
    }
    
    private func saveActiveTime() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(currentActiveTime), forKey:currentActiveTimeKey)
    }
    
    private func saveActiveTimeTracking() {
        UserDefaults.standard.set(currentActiveTimeLocationTracking, forKey:currentActiveTimetrackingKey)
    }
    
    // MARK: - api
    
    func track(experienceId: String, timeId: String) {
        let timeKey = TimeKey(experienceId: experienceId, timeId: timeId)
        guard trackedTimesIds[timeKey] == nil else { return }
        
        trackedTimesIds[timeKey] = [
            Firestore.firestore().document("experiences/\(experienceId)/timeList/\(timeId)")
                .addSnapshotListener { [weak self] (snapshot, error) in
                    if let snapshot = snapshot, snapshot.exists {
                        let time = ExperienceTime.fromSnapshot(snapshot)
                        self?.timeChanged(time)
                    } else if error == nil {
                        self?.timeExpired(experienceId: experienceId, timeId: timeId)
                    } else {
                        self?.removeTracking(experienceId: experienceId, timeId: timeId)
                    }
                }
        ]
        
        save()
    }
    
    func removeTracking(experienceId: String, timeId: String) {
        let timeKey = TimeKey(experienceId: experienceId, timeId: timeId)
        if let listeners = trackedTimesIds[timeKey], let unwraped = listeners {
            for listener in unwraped {
                listener.remove()
            }
        }
        trackedTimesIds.removeValue(forKey: timeKey)
        trackedTimes.removeValue(forKey: timeKey)
    }
    
    private func timeChanged(_ time: ExperienceTime?) {
        guard let time = time else { return }
        
        checkForActiveTime(time)
        
        let timeKey = TimeKey(experienceId: time.post.experience.id, timeId: time.id)
        guard trackedTimesIds[timeKey] != nil else {
            removeTracking(experienceId: timeKey.experienceId, timeId: timeKey.timeId)
            return
        }
        
        if let trackedTime = trackedTimes[timeKey] {
            checkFinished(old: trackedTime, new: time)
            checkLocation(old: trackedTime, new: time)
            trackedTimes[timeKey] = time
        } else {
            if time.expiresAt < Date() {
                removeTracking(experienceId: timeKey.experienceId, timeId: timeKey.timeId)
            } else {
                trackedTimes[timeKey] = time
                NotificationCenter.default.post(name: Notifications.TimeLoaded, object: self, userInfo: ["time": time])
                
                // TODO: - update location
            }
        }
    }
    
    private func checkForActiveTime(_ time: ExperienceTime) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        guard time.chat.memberIds.contains(myId) else { return }
        let now = Date()
        if time.id == currentActiveTime?.id {
            if time.expiresAt < now {
                currentActiveTime = nil
            } else {
                currentActiveTime = time
            }
            saveActiveTime()
        } else if currentActiveTime == nil {
            if time.expiresAt > now {
                currentActiveTime = time
                saveActiveTime()
            }
        }
    }
    
    private func timeExpired(experienceId: String, timeId: String) {
        removeTracking(experienceId: experienceId, timeId: timeId)
        NotificationCenter.default.post(name: Notifications.TimeExpired, object: self, userInfo: ["experienceId": experienceId, "timeId": timeId])
    }
    
    @discardableResult
    private func checkFinished(old: ExperienceTime, new: ExperienceTime) -> Bool {
        if old.isFinished() != new.isFinished() {
            NotificationCenter.default.post(name: Notifications.TimeExpired, object: self, userInfo: ["timeId": new.id])
            return true
        } else {
            var change = old.states?.count != new.states?.count
            if !change, let oldStates = old.states {
                for userId in oldStates.keys {
                    if oldStates[userId] != new.states?[userId] {
                        change = true
                        break
                    }
                }
            }
            if change {
                NotificationCenter.default.post(name: Notifications.TimeStateChanged, object: self, userInfo: ["time": new])
            }
        }
        return false
    }

    private func checkLocation(old: ExperienceTime, new: ExperienceTime) {
        var change = old.distances?.count != new.distances?.count
        if !change, let oldDistances = old.distances {
            for userId in oldDistances.keys {
                if oldDistances[userId] != new.distances?[userId] {
                    change = true
                    break
                }
            }
        }
        if !change {
            change = old.locations?.count != new.locations?.count
        }
        if !change, let oldLocations = old.locations {
            for userId in oldLocations.keys {
                if oldLocations[userId] != new.locations?[userId] {
                    change = true
                    break
                }
            }
        }
        
        if change {
            NotificationCenter.default.post(name: Notifications.TimeLocation, object: self, userInfo: ["time": new])
        }
    }
    
    func updatedTimeData(experienceId: String, timeId: String) -> ExperienceTime? {
        let timeKey = TimeKey(experienceId: experienceId, timeId: timeId)
        return trackedTimes[timeKey]
    }
    
    private func updateTimeLocation(experienceId: String, timeId: String, location: GeoPoint) {
        
    }
    
    func deleteTime(experienceId: String, timeId: String) {
        removeTracking(experienceId: experienceId, timeId: timeId)
        Firestore.firestore().document("experiences/\(experienceId)/timeList/\(timeId)").delete()
        Analytics.logEvent("TimeDeleted", parameters: ["experienceId": experienceId, "timeId": timeId])
    }
    
    func arrivedTime(experienceId: String, timeId: String) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        
        let ref = Firestore.firestore().document("experiences/\(experienceId)/timeList/\(timeId)")
        ref.updateData(["states.\(myId)": ExperienceTimeState.arrived.rawValue])
        Analytics.logEvent("TimeArrived", parameters: ["experienceId": experienceId, "timeId": timeId, "userId": myId])
    }
    
    func metTime(experienceId: String, timeId: String) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        
        let ref = Firestore.firestore().document("experiences/\(experienceId)/timeList/\(timeId)")
        ref.updateData(["states.\(myId)": ExperienceTimeState.met.rawValue])
        Analytics.logEvent("TimeMet", parameters: ["experienceId": experienceId, "timeId": timeId, "userId": myId])
    }
    
    func cancelTime(experienceId: String, timeId: String, flagged: Bool = false, message: String? = nil) {
        guard let me = ProfileService.shared.profile?.shortUser else { return }
        
        let ref = Firestore.firestore().document("experiences/\(experienceId)/timeList/\(timeId)")
        if flagged {
            ref.updateData(["flagged": true])
            Analytics.logEvent("TimeFlagged", parameters: ["experienceId": experienceId, "timeId": timeId, "userId": me.id])
        }
        if let message = message {
            if let time = updatedTimeData(experienceId: experienceId, timeId: timeId) {
                let msgId = "\(me.id.hashValue)-\(Date().hashValue)"
                let msg = Message(id: msgId, createdAt: Date(), sender: me, type: .text, text: message.trimmingCharacters(in: .whitespacesAndNewlines), deliveredAt: nil, readAt: nil)
                ChatService.shared.sendMessage(chatId: time.chat.id, message: msg)
            }
        }
        ref.updateData(["states.\(me.id)": ExperienceTimeState.cancelled.rawValue])
        Analytics.logEvent("TimeCanceled", parameters: ["experienceId": experienceId, "timeId": timeId, "userId": me.id])
    }
    
    func closeTime(experienceId: String, timeId: String) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        
        let ref = Firestore.firestore().document("experiences/\(experienceId)/timeList/\(timeId)")
        ref.updateData(["states.\(myId)": ExperienceTimeState.closed.rawValue])
        Analytics.logEvent("TimeClosed", parameters: ["experienceId": experienceId, "timeId": timeId, "userId": myId])
    }
    
    func sendTimeReview(timeId: String, review: Review, complete: ((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let data = review.json else { return }
        
        Firestore.firestore().collection("times/\(timeId)/reviewList").addDocument(data: data) { (error) in
                if let error = error {
                    complete?(false, error.localizedDescription)
                    return
                }
                
                Analytics.logEvent("TimeReviewed", parameters: ["timeId": timeId])
                complete?(true, nil)
        }
    }
    
    func getTrackedTimes() -> [ExperienceTime] {
        return Array(trackedTimes.values)
    }
    
    func getActiveTime() -> ExperienceTime? {
        if let current = currentActiveTime {
            return current
        }
        return nil
    }
    
    func shareActiveTimeLocation(until: Date) {
        currentActiveTimeLocationTracking = until
        locationUpdate()
        saveActiveTimeTracking()
    }
}
