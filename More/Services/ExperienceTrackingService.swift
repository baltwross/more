//
//  ExperienceTrackingService.swift
//  More
//
//  Created by Luko Gjenero on 09/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

class ExperienceTrackingService {
    
    struct Notifications {
        static let ExperienceChanged = NSNotification.Name(rawValue: "com.more.experience.changed")
        static let ExperienceExpired = NSNotification.Name(rawValue: "com.more.experience.expired")
        static let ExperiencePost = NSNotification.Name(rawValue: "com.more.experience.post")
        static let ExperiencePostChanged = NSNotification.Name(rawValue: "com.more.experience.post.changed")
        static let ExperiencePostExpired = NSNotification.Name(rawValue: "com.more.experience.post.expired")
        static let ExperienceRequest = NSNotification.Name(rawValue: "com.more.experience.request")
        static let ExperienceResponse = NSNotification.Name(rawValue: "com.more.experience.response")
        static let ExperienceTips = NSNotification.Name(rawValue: "com.more.experience.tips")
    }
    
    static let shared = ExperienceTrackingService()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate), name: LocationService.Notifications.LocationUpdate, object: nil)
        
        load()
        
        toForeground()
    }
    
    // MARK: - data
    
    struct TrackedPost {
        var post: ExperiencePost
        var timer: Timer
        var tracking: ListenerRegistration?
    }
    
    struct TrackedExperience {
        var experience: Experience
        // var timer: Timer
        var posts: [TrackedPost] = []
    }
    
    private let trackedExperiencesKey = "com.more.experince.tracked"
    
    private var trackedExperienceIds: [String: [ListenerRegistration]?] = [:]
    private var trackedExperiences: [String: TrackedExperience] = [:]
    
    @objc private func toForeground() {
        // restart tracking
        let trackedIds = trackedExperienceIds
        trackedExperienceIds = [:]
        for (experienceId, _) in trackedIds {
            track(experienceId: experienceId)
        }
    }
    
    @objc private func toBackground() {
        // stop tracking
        let trackedIds = trackedExperienceIds
        for (experienceId, _) in trackedIds {
            if let listeners = trackedExperienceIds[experienceId] {
                if let unwraped = listeners {
                    for listener in unwraped {
                        listener.remove()
                    }
                }
            }
            if let tracked = trackedExperiences[experienceId] {
                for post in tracked.posts {
                    post.tracking?.remove()
                    post.timer.invalidate()
                }
            }
        }
    }
    
    @objc private func locationUpdate() {
        
        guard let coordinates = LocationService.shared.currentLocation?.coordinate else { return }
        
        let now = Date()
        let location = GeoPoint(coordinates: coordinates)
        for experience in getActiveExperiences() {
            if let post = experience.myPost(), post.isActive(now) {
                ExperienceService.shared.updateExperiencePostLocation(experienceId: post.experience.id, postId: post.id, location: location)
            }
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.value(forKey:trackedExperiencesKey) as? Data,
            let trackedExperiences = try? PropertyListDecoder().decode([String: Int].self, from: data) {
            self.trackedExperienceIds = trackedExperiences.mapValues { _ in return nil }
        }
    }
    
    private func save() {
        let trackedExperiences = trackedExperienceIds.mapValues { _ in return 1 }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(trackedExperiences), forKey:trackedExperiencesKey)
    }
    
    // MARK: - api
    
    func track(experienceId: String, forceRefresh: Bool = false) {
        
        guard trackedExperienceIds[experienceId] == nil else {
            if forceRefresh {
                ExperienceService.shared.loadExperience(experienceId: experienceId) { [weak self] (experience, _) in
                    if let experience = experience {
                        self?.experienceChanged(experience)
                        if let posts = experience.posts {
                            self?.checkPosts(posts: posts, for: experience.id)
                        }
                    }
                }
            }
            return
        }
        
        trackedExperienceIds[experienceId] = [
            Firestore.firestore()
                .document("experiences/\(experienceId)")
                .addSnapshotListener { [weak self] (snapshot, error) in
                    if let snapshot = snapshot, snapshot.exists {
                        self?.experienceChanged(Experience.fromSnapshot(snapshot))
                    } else if error != nil {
                        self?.removeTracking(experienceId)
                    } else {
                        // self?.experienceExpired(experienceId, cancelled: true)
                        self?.removeTracking(experienceId)
                    }
            },
            Firestore.firestore()
                .collection("experiences/\(experienceId)/postList")
                .addSnapshotListener { [weak self] (snapshot, error) in
                    if let snapshot = snapshot {
                        var posts: [ExperiencePost] = []
                        for child in snapshot.documents {
                            if let post = ExperiencePost.fromSnapshot(child) {
                                posts.append(post)
                            }
                        }
                        self?.checkPosts(posts: posts, for: experienceId)
                    }
            },
            Firestore.firestore()
                .collection("experiences/\(experienceId)/tipList")
                .addSnapshotListener { [weak self] (snapshot, error) in
                    if let snapshot = snapshot {
                        var tips: [ExperienceTip] = []
                        for child in snapshot.documents {
                            if let post = ExperienceTip.fromSnapshot(child) {
                                tips.append(post)
                            }
                        }
                        self?.checkTips(tips: tips, for: experienceId)
                    }
            },
        ]
        save()
    }
    
    func removeTracking(_ experienceId: String) {
        // trackedExperiences[experienceId]?.timer.invalidate()
        if let listeners = trackedExperienceIds[experienceId] {
            if let unwraped = listeners {
                for listener in unwraped {
                    listener.remove()
                }
            }
        }
        if let tracked = trackedExperiences[experienceId] {
            for post in tracked.posts {
                post.tracking?.remove()
                post.timer.invalidate()
            }
        }
        trackedExperienceIds.removeValue(forKey: experienceId)
        trackedExperiences.removeValue(forKey: experienceId)
        
        NotificationCenter.default.post(name: Notifications.ExperienceChanged, object: self, userInfo: ["experienceId": experienceId])
        
        save()
    }
    
    private func experienceChanged(_ experience: Experience?) {
        guard let experience = experience else { return }
        
        let new = experience.experienceWithPosts(trackedExperiences[experience.id]?.posts.map { $0.post })
        if var trackedExperience = trackedExperiences[experience.id] {
            trackedExperience.experience = experience
            trackedExperiences[experience.id] = trackedExperience
            NotificationCenter.default.post(name: Notifications.ExperienceChanged, object: self, userInfo: ["experience": new])
        } else {
            trackedExperiences[experience.id] = TrackedExperience(experience: experience)
            NotificationCenter.default.post(name: Notifications.ExperienceChanged, object: self, userInfo: ["experience": new])
        }
    }
    
    /*
    private func experienceExpired(_ experienceId: String, cancelled: Bool = false) {
        removeTracking(experienceId)
        NotificationCenter.default.post(name: Notifications.ExperienceExpired, object: self, userInfo: ["experienceId": experienceId])
    }
    */
    
    private func postExpired(experienceId: String, postId: String) {
        if var tracked = trackedExperiences[experienceId] {
            if let idx = tracked.posts.firstIndex(where: { $0.post.id == postId}) {
                let post = tracked.posts[idx]
                post.tracking?.remove()
                post.timer.invalidate()
                tracked.posts.remove(at: idx)
                
                trackedExperiences[experienceId] = tracked
                
                NotificationCenter.default.post(name: Notifications.ExperiencePostExpired, object: self, userInfo: ["experienceId": experienceId, "postId": postId])
            }
        }
    }
    
    private func checkPosts(posts: [ExperiencePost], for experienceId: String) {
        guard var tracked = trackedExperiences[experienceId] else { return }
        
        //  get new, changed & removed
        let new = posts.filter { (p) in !tracked.posts.contains { (tp) -> Bool in tp.post.id == p.id } }
        let changed = posts.filter { (p) in tracked.posts.contains { (tp) -> Bool in tp.post.id == p.id } }
        let removed = tracked.posts.filter { (tp) in !posts.contains { (p) in tp.post.id == p.id } }
        
        //  removed
        if !removed.isEmpty {
            for post in removed {
                postExpired(experienceId: experienceId, postId: post.post.id)
            }
            if let updated = trackedExperiences[experienceId] {
                tracked = updated
            }
        }
        
        // changed
        for post in changed {
            if let idx = tracked.posts.firstIndex(where: { $0.post.id == post.id }) {
                var trackedPost = tracked.posts[idx]
                trackedPost.post = post.postWithRequests(trackedPost.post.requests)
                trackedPost.timer.invalidate()
                trackedPost.timer = postExpiration(post)
                tracked.posts.remove(at: idx)
                tracked.posts.insert(trackedPost, at: idx)
                trackedExperiences[experienceId] = tracked
                
                NotificationCenter.default.post(name: Notifications.ExperiencePostChanged, object: self, userInfo: ["experienceId": experienceId, "post": post])
            }
        }
        
        // new
        for post in new {
            var tp = TrackedPost(
                post: post,
                timer: postExpiration(post),
                tracking: nil)
            tracked.posts.append(tp)
            trackedExperiences[experienceId] = tracked
            
            let tracking =
            Firestore.firestore().collection("experiences/\(experienceId)/postList/\(post.id)/requestList")
                .addSnapshotListener { [weak self] (snapshot, error) in
                    guard let snapshot = snapshot else { return }
                    snapshot.documentChanges.forEach { diff in
                        if let request = ExperienceRequest.fromSnapshot(diff.document) {
                            if (diff.type == .added) {
                                self?.newRequest(request, experienceId: experienceId, postId: post.id)
                            }
                            if (diff.type == .modified) {
                                self?.updatedRequest(request, experienceId: experienceId, postId: post.id)
                            }
                            if (diff.type == .removed) {
                                self?.removedRequest(request, experienceId: experienceId, postId: post.id)
                            }
                        }
                    }
                }
            tp.tracking = tracking

            NotificationCenter.default.post(name: Notifications.ExperiencePost, object: self, userInfo: ["experienceId": experienceId, "post": post])
        }
    }
    
    private func checkTips(tips: [ExperienceTip], for experienceId: String) {
        if var tracked = trackedExperiences[experienceId] {
            tracked.experience = tracked.experience.experienceWithTips(tips)
            trackedExperiences[experienceId] = tracked
            NotificationCenter.default.post(name: Notifications.ExperienceTips, object: self, userInfo: ["experience": tracked.experience])
        }
    }
    
    private func newRequest(_ request: ExperienceRequest, experienceId: String, postId: String) {
        guard var tracked = trackedExperiences[experienceId] else { return }
        guard var post = tracked.posts.first(where: { $0.post.id == postId }) else { return }
        
        var requests = post.post.requests ?? []
        requests.append(request)
        post.post = post.post.postWithRequests(requests)
        
        if let idx = tracked.posts.firstIndex(where: { $0.post.id == postId }) {
            tracked.posts.remove(at: idx)
            tracked.posts.insert(post, at: idx)
        }
        trackedExperiences[experienceId] = tracked
        
        NotificationCenter.default.post(name: Notifications.ExperienceRequest, object: self, userInfo: ["experienceId": experienceId, "postId": postId, "request": request])
    }
    
    private func updatedRequest(_ request: ExperienceRequest, experienceId: String, postId: String) {
        guard var tracked = trackedExperiences[experienceId] else { return }
        guard var post = tracked.posts.first(where: { $0.post.id == postId }) else { return }
        
        var requests = post.post.requests ?? []
        if let idx = requests.firstIndex(where: { $0.id == request.id }) {
            requests.remove(at: idx)
            requests.insert(request, at: idx)
        }
        post.post = post.post.postWithRequests(requests)
        
        if let idx = tracked.posts.firstIndex(where: { $0.post.id == postId }) {
            tracked.posts.remove(at: idx)
            tracked.posts.insert(post, at: idx)
        }
        trackedExperiences[experienceId] = tracked
        
        NotificationCenter.default.post(name: Notifications.ExperienceRequest, object: self, userInfo: ["experienceId": experienceId, "postId": postId, "request": request])
    }
    
    private func removedRequest(_ request: ExperienceRequest, experienceId: String, postId: String) {
        guard let tracked = trackedExperiences[experienceId] else { return }
        guard var post = tracked.posts.first(where: { $0.post.id == postId }) else { return }
        
        var requests = post.post.requests ?? []
        if let idx = requests.firstIndex(where: { $0.id == request.id }) {
            requests.remove(at: idx)
        }
        post.post = post.post.postWithRequests(requests)
        
        if post.post.creator.isMe() {
            NotificationCenter.default.post(name: Notifications.ExperienceRequest, object: self, userInfo: ["experienceId": experienceId, "postId": postId, "request": request])
        } else {
            postExpired(experienceId: experienceId, postId: postId)
        }
    }

    
    /*
    private func experienceExpiration(_ experience: Experience) -> Timer {
        let delay = Date().timeIntervalSinceNow
        return Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] (_) in
            self?.signalExpired(signal.id)
        }
    }
    */
    
    private func postExpiration(_ post: ExperiencePost) -> Timer {
        let delay = post.expiresAt.timeIntervalSinceNow
        return Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] (_) in
            self?.postExpired(experienceId: post.experience.id, postId: post.id)
        }
    }
    
    func updatedExperienceData(for experienceId: String) -> Experience? {
        if let trackedExperience = trackedExperiences[experienceId] {
            return trackedExperience.experience.experienceWithPosts(trackedExperience.posts.map { $0.post })
        }
        return nil
    }
    
    func getActiveExperiences() -> [Experience] {
        let now = Date()
        var experiences: [Experience] = []
        for trackedExperience in trackedExperiences.values {
            let experience =
                trackedExperience.experience.experienceWithPosts(trackedExperience.posts.map { $0.post })
            
            if let post = experience.myPost(), post.isActive(now) {
                experiences.append(experience)
                continue
            }
            
            if let request = experience.myRequest(),
                let post = experience.post(for: request.id), post.isActive(now) {
                experiences.append(experience)
            }
        }
        return experiences
    }
    
    func getTrackedExperiences() -> [Experience] {
        return trackedExperiences.values.map { $0.experience.experienceWithPosts($0.posts.map { $0.post }) }
    }
}
