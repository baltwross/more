//
//  ProfileService.swift
//  More
//
//  Created by Luko Gjenero on 29/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import Geofirestore

private let noProfileError = "Profile does not exist"

class ProfileService {
        
    enum ProfilePhase: Int {
        case phoneLogin
        case authentication
        case terms
        case requestLocation
        case locationNeeded
        case notAvailable
        case available
        case info
        case instagram
        case memories
        case photo
        case invite
        case ready
    }

    struct Notifications {
        static let ProfileLogin = NSNotification.Name(rawValue: "com.more.profile.login")
        static let ProfileLogout = NSNotification.Name(rawValue: "com.more.profile.logut")
        
        static let ProfileLoaded = NSNotification.Name(rawValue: "com.more.profile.loaded")
        static let ProfileUpdated = NSNotification.Name(rawValue: "com.more.profile.updated")
        static let ProfilePhotos = NSNotification.Name(rawValue: "com.more.profile.photos")
        
        static let BlockedLoaded = NSNotification.Name(rawValue: "com.more.profile.blocked")
        static let ReportedLoaded = NSNotification.Name(rawValue: "com.more.profile.reported")
    }
    
    static let shared = ProfileService()
    
    init() {
        geoFireRef = Firestore.firestore().collection("userLocations")
        geoFire = GeoFirestore(collectionRef: geoFireRef)
        
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: LocationService.Notifications.LocationUpdate, object: nil)
        
        load()
        toForeground()
    }
    
    private let geoFireRef: CollectionReference
    private let geoFire: GeoFirestore
    
    // MARK: - data
    
    private let profileKey = "com.more.profile.data"
    
    private(set) var profile: Profile?
    
    private(set) var blocked: [String] = []
    
    private(set) var reported: [String] = []
    
    @objc private func toForeground() {
        guard profile != nil else { return }
        loadProfile(complete: nil)
        startTracking()
    }
    
    @objc private func toBackground() {
        save()
        stopTracking()
    }
    
    @objc private func locationUpdated() {
        if let location = LocationService.shared.currentLocation {
            updateLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.value(forKey:profileKey) as? Data {
            profile = try? PropertyListDecoder().decode(Profile.self, from: data)
        }
    }
    
    private func save() {
        if let profile = profile {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(profile), forKey:profileKey)
        }
    }
    
    // MARK: - state
    
    var profilePhase: ProfilePhase {
        
        // return .phoneLogin
        
        guard let profile = profile, Auth.auth().currentUser != nil else {
            return .phoneLogin
        }
        
        /*
        if profile.authVerificationID == nil {
            return .authentication
        }
        */
        
        if !profile.terms {
            return .terms
        }
        
        if !LocationService.locationEnabled {
            if LocationService.canRequestLocation {
                return .requestLocation
            }
            return .locationNeeded
        }
        
        if !PushNotificationService.shared.permissionsRequested {
            return .available
        }
        
        if profile.firstName == nil || profile.lastName == nil || profile.email == nil {
            return .info
        }
        
//        if profile.instagram == nil {
//            return .instagram
//        }
//
//        if profile.memories == nil {
//            return .memories
//        }
        
        if profile.images == nil || profile.images?.isEmpty == true {
            return .photo
        }
        
//        if !profile.verified {
//            return .invite
//        }
        
        return .ready
    }
    
    // MARK: - login, logout, delete
    
    private func login(phoneNumber: String, formattedPhoneNumber: String, authVerificationID: String) {
        let profile = Profile(phoneNumber: phoneNumber, formattedPhoneNumber: formattedPhoneNumber, authVerificationID: authVerificationID)
        self.profile = profile
        save()
    }
    
    func logout(complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        do {
            try Auth.auth().signOut()
            profile = nil
            NotificationCenter.default.post(name: Notifications.ProfileLogout, object: self)
            stopTracking()
            complete?(true, nil)
        } catch {
            profile = nil
            complete?(false, error.localizedDescription)
        }
    }
    
    func deleteAccount(complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let id = profile?.getId() else {
            complete?(false, "Not logged in")
            return
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            complete?(false, "Not logged in")
            return
        }
        
        Firestore.firestore().collection("users").document(id).delete(completion: { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
            } else {
                currentUser.delete(completion: { [weak self] (error) in
                    self?.logout(complete: complete)
                })
            }
        })
    }
    
    // MARK: - data update
    
    func updateTerms(_ terms: Bool) {
        profile?.terms = terms
        save()
        saveProfile(complete: nil)
    }
    
    func updateLocation(latitude: Double, longitude: Double) {
        guard let id = profile?.getId() else { return }
        geoFire.setLocation(geopoint: GeoPoint(latitude: latitude, longitude: longitude), forDocumentWithID: id)
    }
    
    func updateReferral(referral: String) {
        profile?.referral = referral
        save()
        saveProfile(complete: nil)
    }
    
    func updateInfo(firstName: String, lastName: String, email: String) {
        profile?.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile?.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile?.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
        saveProfile(complete: nil)
    }
    
    func updateInstagram(_ instagram: String) {
        profile?.instagram = instagram.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
        saveProfile(complete: nil)
    }
    
    func updateMemories(_ memories: String) {
        profile?.memories = memories.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
        saveProfile(complete: nil)
    }
    
    func updateInviteLink(_ inviteLink: String) {
        profile?.inviteLink = inviteLink.trimmingCharacters(in: .whitespacesAndNewlines)
        profile?.verified = true
        save()
        saveProfile(complete: nil)
    }
    
    func updateDeviceToken(_ token: String) {
        profile?.iOSDeviceToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let id = profile?.getId() else { return }
        Firestore.firestore().document("users/\(id)").updateData(["iOSDeviceToken": token])
    }
    
    func updateRegistrationToken(_ token: String) {
        profile?.registrationToken = token
        
        guard let id = profile?.getId() else { return }
        Firestore.firestore().document("users/\(id)").updateData(["registrationToken": token])
    }

    func updateBirthday(_ birthday: Date) {
        profile?.birthday = birthday

        guard let id = profile?.getId() else { return }
        Firestore.firestore().document("users/\(id)").updateData(["birthday": birthday.timeIntervalSinceReferenceDate])
        ProfileService.shared.updateUserProperties()
    }

    func updateQuote(quote: String?, author: String?) {
        profile?.quote = quote?.trimmingCharacters(in: .whitespacesAndNewlines)
        profile?.quoteAuthor = author?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let id = profile?.getId() else { return }
        var data: [String: Any] = [:]
        if let quote = quote {
            data["quote"] = quote
        }
        if let author = author {
            data["quoteAuthor"] = author
        }
        guard !data.isEmpty else { return }
        Firestore.firestore().document("users/\(id)").updateData(data)
    }

    func updateGender(_ gender: String?) {
        profile?.gender = gender?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let id = profile?.getId() else { return }
        if let gender = gender {
            Firestore.firestore().document("users/\(id)").updateData(["gender": gender])
        }
        updateUserProperties()
    }
    
    func updateImages(_ images: [Image]?) {
        let oldImages = profile?.images ?? []
        var newImages: [Image] = []
        if let images = images {
            newImages = images.map { $0.imageWithOrder(images.firstIndex(of: $0) ?? 0) }
            profile?.images = newImages
        } else {
            profile?.images = nil
        }
        
        guard let id = profile?.getId() else { return }
        
        var deleted: [Image] = oldImages
        var added: [Image] = []
        var changed: [Image] = []
        deleted = oldImages.filter { !newImages.contains($0) }
        added = newImages.filter { !oldImages.contains($0) }
        changed = oldImages.filter { !deleted.contains($0) }
        for image in deleted {
            Firestore.firestore().document("users/\(id)/imageList/\(image.id)").delete()
        }
        for image in added {
            if let data = image.json {
                Firestore.firestore().document("users/\(id)/imageList/\(image.id)").setData(data)
            }
        }
        for image in changed {
            if let newImage = newImages.first(where: { $0.id == image.id }), newImage.order != image.order {
                Firestore.firestore().document("users/\(id)/imageList/\(newImage.id)")
                    .updateData(["order": newImage.order])
            }
        }
        
        if !(oldImages.first?.url == newImages.first?.url) {
            updatePhotos()
        }
        
        NotificationCenter.default.post(name: Notifications.ProfilePhotos, object: self)
    }
    
    // MARK: - api
    
    func verifyPhoneNumber(phoneNumber: String, formattedPhoneNumber: String, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            
            if let error = error {
                complete?(false, error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                return
            }
            
            ProfileService.shared.login(
                phoneNumber: phoneNumber,
                formattedPhoneNumber: formattedPhoneNumber,
                authVerificationID: verificationID ?? "")
            
            complete?(true, nil)
        }
    }
    
    func signIn(verificationCode: String, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        let authVerificationID = ProfileService.shared.profile?.authVerificationID ?? ""
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: authVerificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
            if let error = error {
                complete?(false, error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                return
            }
            
            guard let uid = authResult?.user.uid else {
                complete?(false, "Unknown user")
                return
            }
            
            ProfileService.shared.profile?.verificationCode = verificationCode
            ProfileService.shared.profile?.id = uid
            ProfileService.shared.save()
            
            ProfileService.shared.createProfileIfNeeded(complete: { (success, errorMsg) in
                if success {
                    NotificationCenter.default.post(name: Notifications.ProfileLogin, object: ProfileService.shared)
                }
                complete?(success, errorMsg)
            })
        }
        
    }
    
    func createProfileIfNeeded(complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        guard let id = profile?.getId() else {
            complete?(false, "Not logged in")
            return
        }
        
        loadProfile(withId: id) { (profile, errorMsg) in
            if let profile = profile {
                ProfileService.shared.profile?.update(from: profile)
                ProfileService.shared.save()
                ProfileService.shared.updateUserProperties()
                complete?(true, nil)
            } else {
                if errorMsg == noProfileError {
                    ProfileService.shared.createProfile(complete: { (success, errorMsg) in
                        if success {
                            ProfileService.shared.checkUserLeads(complete: complete)
                        } else {
                            complete?(success, errorMsg)
                        }
                    })
                } else {
                    complete?(false, errorMsg ?? "Error")
                    let error = NSError(domain:"com.more.loadprofile", code:-1, userInfo:["description": errorMsg ?? "Unknown error"])
                    Crashlytics.crashlytics().record(error: error)
                }
            }
        }
    }
    
    func createProfile(complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        guard let id = profile?.getId(),
            let data = profile?.json else {
            complete?(false, "Not logged in")
            return
        }
        
        Firestore.firestore().document("users/\(id)").setData(data) { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                Crashlytics.crashlytics().record(error: error)
                return
            }
            complete?(true, nil)
        }
    }
    
    func checkUserLeads(complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let phoneNumber = profile?.phoneNumber else {
            complete?(false, "Not logged in")
            return
        }
        
        let fixedNumber = phoneNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
        
        Firestore.firestore().document("userleads/\(fixedNumber)").getDocument { (snapshot, error) in
            
            if let snapshot = snapshot, snapshot.exists {
                if let value = snapshot.data() {
                    var save = false
                    if let firstName = value["firstName"] as? String {
                        ProfileService.shared.profile?.firstName = firstName
                        save = true
                    }
                    if let lastName = value["lastName"] as? String {
                        ProfileService.shared.profile?.lastName = lastName
                        save = true
                    }
                    if let email = value["email"] as? String {
                        ProfileService.shared.profile?.email = email
                        save = true
                    }
                    if let instagram = value["instagram"] as? String {
                        ProfileService.shared.profile?.instagram = instagram
                        save = true
                    }
                    if let moreMoment = value["moreMoment"] as? String {
                        ProfileService.shared.profile?.memories = moreMoment
                        save = true
                    }
                    if let referral = value["referral"] as? String {
                        ProfileService.shared.profile?.referral = referral
                        save = true
                    }
                    if let isAdmin = value["isAdmin"] as? Bool {
                        ProfileService.shared.profile?.isAdmin = isAdmin
                        save = true
                    }
                    if save {
                        LinkService.inviteLink(complete: { (url) in
                            ProfileService.shared.profile?.inviteLink = url.absoluteString
                            ProfileService.shared.profile?.verified = true
                            ProfileService.shared.save()
                            ProfileService.shared.saveProfile(complete: nil)
                            ProfileService.shared.updateUserProperties()
                            complete?(true, nil)
                        })
                    }
                }
                complete?(true, nil)
            } else {
                complete?(true, nil)
            }
        }
    }
    
    func loadProfile(complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        guard let id = profile?.getId() else {
            complete?(false, "Not logged in")
            return
        }
        
        loadProfile(withId: id) { (profile, errorMsg) in
            if let profile = profile {
                ProfileService.shared.profile?.update(from: profile)
                ProfileService.shared.save()
                ProfileService.shared.updateUserProperties()
                NotificationCenter.default.post(name: Notifications.ProfileLoaded, object: self)
                NotificationCenter.default.post(name: Notifications.ProfilePhotos, object: self)
                Crashlytics.crashlytics().setUserID(profile.id)
            } else {
                complete?(false, errorMsg ?? "Error")
            }
        }
    }
    
    func saveProfile(complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        guard let id = profile?.getId(),
            let data = profile?.json else {
                complete?(false, "Not logged in")
                return
        }
        
        Firestore.firestore().document("users/\(id)").updateData(data) { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                return
            }
            complete?(true, nil)
        }
    }
    
    private func updateUserProperties() {
        guard let id = profile?.getId() else { return }
        
        Analytics.setUserProperty(id, forName: "more_id")
        if let gender = profile?.gender {
            Analytics.setUserProperty(gender, forName: "gender")
        }
        let isAdmin = profile?.isAdmin ?? false
        Analytics.setUserProperty("\(isAdmin)", forName: "isAdmin")
        if let birthday = profile?.birthday,
            let age = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year, age > 0 {
            Analytics.setUserProperty("\(age)", forName: "age")
        }
    }
    
    func blockUser(withId id: String) {
        guard let myId = profile?.getId() else { return }
        
        Firestore.firestore().document("users/\(myId)/blocked/\(id)").setData([ "timestamp": Date() ])
    }
    
    func reportExperience(withId id: String) {
        guard let myId = profile?.getId() else { return }
        
        Firestore.firestore().document("users/\(myId)/reported/\(id)").setData([ "timestamp": Date() ])
    }
    
    // MARK: - tracking data
    
    private var listeners: [ListenerRegistration] = []
    
    private func startTracking() {
        stopTracking()
        guard let id = profile?.getId() else { return }
        
        // active posts
        listeners.append(
            Firestore.firestore().collection("users/\(id)/posts").addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                for child in snapshot.documents {
                    if let post = ShortExperiencePost.fromSnapshot(child) {
                        Firestore.firestore().document(ExperienceService.Paths.post(post.experience.id, post.id))
                            .getDocument { (snapshot, _) in
                                if let snapshot = snapshot, !snapshot.exists {
                                    Firestore.firestore().document("users/\(id)/posts/\(post.id)").delete()
                                } else {
                                    ExperienceTrackingService.shared.track(experienceId: post.experience.id)
                                }
                        }
                    }
                }
            }
        )
        
        // active requests
        listeners.append(
            Firestore.firestore().collection("users/\(id)/requests").addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                for child in snapshot.documents {
                    if let request = ShortExperienceRequest.fromSnapshot(child) {
                        Firestore.firestore().document(ExperienceService.Paths.request(request.post.experience.id, request.post.id, request.id))
                            .getDocument { (snapshot, _) in
                                if let snapshot = snapshot, !snapshot.exists {
                                    Firestore.firestore().document("users/\(id)/requests/\(request.id)").delete()
                                } else {
                                    ExperienceTrackingService.shared.track(experienceId: request.post.experience.id)
                                }
                        }
                    }
                }
            }
        )
        
        // active times
        listeners.append(
            Firestore.firestore().collection("users/\(id)/times").addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                for child in snapshot.documents {
                    if let time = ExperienceTime.fromSnapshot(child) {
                        Firestore.firestore().document(ExperienceService.Paths.time(time.post.experience.id, time.id))
                            .getDocument { (snapshot, _) in
                                if let snapshot = snapshot, !snapshot.exists {
                                    Firestore.firestore().document("users/\(id)/times/\(time.id)").delete()
                                } else {
                                    TimesService.shared.track(experienceId: time.post.experience.id, timeId: time.id)
                                }
                        }
                    }
                }
            }
        )
        
        // reviews - TODO: ??
        
        // blocked
        listeners.append(
            Firestore.firestore().collection("users/\(id)/blocked").addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                ProfileService.shared.blocked.removeAll()
                for child in snapshot.documents {
                    ProfileService.shared.blocked.append(child.documentID)
                }
                NotificationCenter.default.post(name: Notifications.BlockedLoaded, object: self)
            }
        )
        
        // reported
        listeners.append(
            Firestore.firestore().collection("users/\(id)/reported").addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                ProfileService.shared.reported.removeAll()
                for child in snapshot.documents {
                    ProfileService.shared.reported.append(child.documentID)
                }
                NotificationCenter.default.post(name: Notifications.ReportedLoaded, object: self)
            }
        )
        
        // number of goings
        listeners.append(
            Firestore.firestore().document("users/\(id)").addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot, snapshot.exists else { return }
                guard let data = snapshot.data() else { return }
                var loaded = false
                if let numberOfGoings = data["numberOfGoings"] as? Int,
                    numberOfGoings != ProfileService.shared.profile?.numberOfGoings {
                    ProfileService.shared.profile?.numberOfGoings = numberOfGoings
                    loaded = true
                }
                if let numberOfDesigned = data["numberOfDesigned"] as? Int,
                    numberOfDesigned != ProfileService.shared.profile?.numberOfDesigned {
                    ProfileService.shared.profile?.numberOfDesigned = numberOfDesigned
                    loaded = true
                }
                if loaded {
                    NotificationCenter.default.post(name: Notifications.ProfileLoaded, object: self)
                }
            }
        )
    }
    
    private func stopTracking() {
        for listener in listeners {
            listener.remove()
        }
        listeners.removeAll()
    }
    
    // MARK: - load profiles
    
    func loadProfile(withId userId: String, complete:((_ profile: Profile?, _ errorMsg: String?)->())?) {
        
        Firestore.firestore().document("users/\(userId)").getDocument { [weak self] (snapshot, error) in
            if let snapshot = snapshot, snapshot.exists,
                let profile = Profile.fromSnapshot(snapshot) {
                self?.loadProfileImages(profile: profile, complete: { (profile, errorMsg) in
                    self?.loadProfileReviews(profile: profile, complete: { (profile, errorMsg) in
                        complete?(profile, nil)
                    })
                })
            } else if let error = error {
                complete?(nil, error.localizedDescription)
            } else {
                complete?(nil, noProfileError)
            }
        }
    }
    
    private func loadProfileImages(profile: Profile, complete:((_ profile: Profile, _ errorMsg: String?)->())?) {
        
        Firestore.firestore().collection("users/\(profile.id)/imageList").getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                var images: [Image] = []
                for child in snapshot.documents {
                    if let image = Image.fromSnapshot(child) {
                        images.append(image)
                    }
                }
                images.sort(by: { (lhs, rhs) -> Bool in
                    return lhs.order < rhs.order
                })
                var updated = profile
                updated.images = images
                complete?(updated, nil)
            } else if let error = error {
                complete?(profile, error.localizedDescription)
            } else {
                complete?(profile, "Images do not exist")
            }
        }
    }
    
    private func loadProfileReviews(profile: Profile, complete:((_ profile: Profile, _ errorMsg: String?)->())?) {
        
        Firestore.firestore().collection("users/\(profile.id)/reviewList").getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                var reviews: [Review] = []
                for child in snapshot.documents {
                    if let review = Review.fromSnapshot(child) {
                        reviews.append(review)
                    }
                }
                var updated = profile
                updated.reviews = reviews
                complete?(updated, nil)
            } else if let error = error {
                complete?(profile, error.localizedDescription)
            } else {
                complete?(profile, "Reviews do not exist")
            }
        }
    }
    
    // Profile view
    
    func userModel() -> UserViewModel? {
        guard let profile = profile else { return nil }
        return UserViewModel(profile: profile)
    }
    
    // update photos
    
    private func updatePhotos() {
        guard let me = profile else { return }
        
        let avatar = profile?.images?.first?.url
        let update = ["creator.avatar": avatar ?? ""]
        
        // update experience which I created
        Firestore.firestore().collection(ExperienceService.Paths.experiences)
            .whereField("creator.id", isEqualTo: me.id)
            .getDocuments(completion: { (snapshot, error) in
                guard let snapshot = snapshot, !snapshot.isEmpty else { return }
                snapshot.documents.forEach { document in
                    Firestore.firestore()
                        .document(ExperienceService.Paths.experience(document.documentID))
                        .updateData(update)
                }
            })
        
        // update posts & requests
        for experience in ExperienceTrackingService.shared.getActiveExperiences() {
            if let post = experience.myPost() {
                Firestore.firestore()
                    .document(ExperienceService.Paths.post(post.experience.id, post.id))
                    .updateData(update)
            }
            if let request = experience.myRequest() {
                Firestore.firestore()
                    .document(ExperienceService.Paths.request(request.post.experience.id, request.post.id, request.id))
                    .updateData(update)
            }
        }
    }

}
