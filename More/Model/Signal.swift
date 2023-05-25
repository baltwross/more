//
//  Signal.swift
//  More
//
//  Created by Anirudh Bandi on 8/2/18.
//  Copyright © 2018 Anirudh Bandi. All rights reserved.
//

import UIKit
import CoreLocation
import Lottie
import Firebase

enum SignalType: String, Codable {
    case magical, chill, adventurous, sporty, creative, intellectual, boozy, rebellious, romantic, lit, foodie
    
    static var all: [SignalType] {
        return [.magical, .chill, .adventurous, .sporty, .creative, .intellectual, .boozy, .rebellious, .romantic, .lit, .foodie]
    }
    
    var color: UIColor {
        switch self {
        case .magical:
            return UIColor(red: 119, green: 103, blue: 251)
        case .chill:
            return UIColor(red: 134, green: 208, blue: 255)
        case .adventurous:
            return UIColor(red: 0, green: 156, blue: 255)
        case .sporty:
            return UIColor(red: 47, green: 255, blue: 238)
        case .creative:
            return UIColor(red: 181, green: 217, blue: 4)
        case .intellectual:
            return UIColor(red: 251, green: 199, blue: 90)
        case .boozy:
            return UIColor(red: 250, green: 118, blue: 23)
        case .rebellious:
            return UIColor(red: 255, green: 95, blue: 88)
        case .romantic:
            return UIColor(red: 255, green: 61, blue: 189)
        case .lit:
            return UIColor(red: 80, green: 114, blue: 255)
        case .foodie:
            return UIColor(rgb: 0x39da8d)
        }
    }
    
    var gradient: (UIColor, UIColor) {
        switch self {
        case .magical:
            return (UIColor(red: 119, green: 103, blue: 251), UIColor(red: 248, green: 101, blue: 251))
        case .chill:
            return (UIColor(red: 134, green: 208, blue: 255), UIColor(red: 215, green: 254, blue: 255))
        case .adventurous:
            return (UIColor(red: 0, green: 156, blue: 255), UIColor(red: 80, green: 253, blue: 253))
        case .sporty:
            return (UIColor(red: 47, green: 255, blue: 238), UIColor(red: 131, green: 255, blue: 99))
        case .creative:
            return (UIColor(red: 181, green: 217, blue: 4), UIColor(red: 192, green: 255, blue: 18))
        case .intellectual:
            return (UIColor(red: 251, green: 199, blue: 90), UIColor(red: 255, green: 244, blue: 41))
        case .boozy:
            return (UIColor(red: 250, green: 118, blue: 23), UIColor(red: 255, green: 191, blue: 0))
        case .rebellious:
            return (UIColor(red: 255, green: 95, blue: 88), UIColor(red: 255, green: 71, blue: 149))
        case .romantic:
            return (UIColor(red: 255, green: 61, blue: 189), UIColor(red: 202, green: 71, blue: 255))
        case .lit:
            return (UIColor(red: 80, green: 114, blue: 255), UIColor(red: 31, green: 174, blue: 255))
        case .foodie:
            return (UIColor(rgb: 0x39da8d), UIColor(rgb: 0x4fcde5))
        }
    }
    
    var pathGradient: (UIColor, UIColor, UIColor) {
        switch self {
        case .magical:
            return (UIColor(rgb: 0x8365fb), UIColor(rgb: 0xb965fb), UIColor(rgb: 0xd634ff))
        case .chill:
            return (UIColor(rgb: 0xb3c1ff), UIColor(rgb: 0x8fd4ff), UIColor(rgb: 0xa7f8fb))
        case .adventurous:
            return (UIColor(rgb: 0x69e3ff), UIColor(rgb: 0x00f7ff), UIColor(rgb: 0x2ffeb3))
        case .sporty:
            return (UIColor(rgb: 0x3cff00), UIColor(rgb: 0x00ffd1), UIColor(rgb: 0x02f7c4))
        case .creative:
            return (UIColor(rgb: 0xb5ff00), UIColor(rgb: 0xdbff00), UIColor(rgb: 0xe1ff00))
        case .intellectual:
            return (UIColor(rgb: 0xfbdc5b), UIColor(rgb: 0xfff029), UIColor(rgb: 0xfffd0a))
        case .boozy:
            return (UIColor(rgb: 0xff9900), UIColor(rgb: 0xffc700), UIColor(rgb: 0xffe500))
        case .rebellious:
            return (UIColor(rgb: 0xff0d00), UIColor(rgb: 0xff2990), UIColor(rgb: 0xff00d6))
        case .romantic:
            return (UIColor(rgb: 0xff1cb3), UIColor(rgb: 0xdb26ff), UIColor(rgb: 0xca47ff))
        case .lit:
            return (UIColor(rgb: 0x5072ff), UIColor(rgb: 0x1faeff), UIColor(rgb: 0x1fe4ff))
        case .foodie:
            return (UIColor(rgb: 0x4fcde5), UIColor(rgb: 0x3fd6a6), UIColor(rgb: 0x4bffa8))
        }
    }
    
    var pathEnd: (UIColor, UIColor) {
        switch self {
        case .magical:
            return (UIColor(rgb: 0x8863ff), UIColor(rgb: 0x901ec6))
        case .chill:
            return (UIColor(rgb: 0x99eaff), UIColor(rgb: 0x75c5ff))
        case .adventurous:
            return (UIColor(rgb: 0x5cffdd), UIColor(rgb: 0x01e7ef))
        case .sporty:
            return (UIColor(rgb: 0x36ff13), UIColor(rgb: 0x02dec4))
        case .creative:
            return (UIColor(rgb: 0xccff00), UIColor(rgb: 0xc0dd04))
        case .intellectual:
            return (UIColor(rgb: 0xfeec32), UIColor(rgb: 0xfbc75a))
        case .boozy:
            return (UIColor(rgb: 0xffc700), UIColor(rgb: 0xfe9800))
        case .rebellious:
            return (UIColor(rgb: 0xff398c), UIColor(rgb: 0xea1005))
        case .romantic:
            return (UIColor(rgb: 0xff3dbd), UIColor(rgb: 0xca47ff))
        case .lit:
            return (UIColor(rgb: 0x1faeff), UIColor(rgb: 0x5072ff))
        case .foodie:
            return (UIColor(rgb: 0x4afda8), UIColor(rgb: 0x48d1cb))
        }
    }
    
    var progressImage: UIImage {
        let (startColor, endColor) = self.gradient
        return UIImage.gradientImage(size: CGSize(width: 64, height: 64), start: CGPoint.zero, end: CGPoint(x: 64, y: 64), startColor: startColor, endColor: endColor) ?? UIImage()
    }
    
    static func image(for type: SignalType) -> UIImage {
        return UIImage(named: type.rawValue) ?? UIImage(named: "boozy")!
    }
    
    static func grayscaleImage(for type: SignalType) -> UIImage {
        return UIImage(named: "\(type.rawValue)_gray") ?? UIImage(named: "boozy_gray")!
    }
    
    static func animation(for type: SignalType) -> LottieAnimationView? {
        let path = Bundle.main.path(forResource: type.rawValue, ofType: "json", inDirectory: "Animations/\(type.rawValue)")!
        
        let lottieView = LottieAnimationView(filePath: path)
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        return lottieView
    }
    
    
}

enum SignalKind: String, Codable {
    case standard, claimable, curated
    
}

struct Signal : Codable, Hashable, MoreDataObject {
    
    let id: String
    let title: String?
    let text: String
    let images: [Image]
    let manageImages: Bool

    var kind: SignalKind? = .standard
    let type: SignalType
    let radius: Double?
    let kindDailyStart: TimeInterval?
    let kindDailyDuration: TimeInterval?
    
    let createdAt: Date
    let expiresAt: Date
    
    let location: GeoPoint?
    let destination: GeoPoint?
    let destinationName: String?
    let destinationAddress: String?
    
    let creator: User
    
    let requests: [Request]? // collection
    
    init(id: String,
         title: String?,
         text: String,
         images: [Image],
         manageImages: Bool = true,
         kind: SignalKind? = nil,
         type: SignalType,
         radius: Double? = nil,
         kindDailyStart: TimeInterval? = nil,
         kindDailyDuration: TimeInterval? = nil,
         createdAt: Date,
         expiresAt: Date,
         location: GeoPoint?,
         destination: GeoPoint?,
         destinationName: String?,
         destinationAddress: String?,
         creator: User,
         requests: [Request]? = nil) {
        
        self.id = id
        self.title = title
        self.text = text
        self.images = images
        self.manageImages = manageImages
        self.kind = kind ?? .standard
        self.type = type
        self.radius = radius
        self.kindDailyStart = kindDailyStart
        self.kindDailyDuration = kindDailyDuration
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.location = location
        self.destination = destination
        self.destinationName = destinationName
        self.destinationAddress = destinationAddress
        self.creator = creator
        self.requests = requests
    }
    
    static func mock(id: String) -> Signal {
        return Signal(id: id,
                      title: nil,
                      text: "Mock text",
                      images: [],
                      type: .boozy,
                      createdAt: Date(timeIntervalSinceNow: 0),
                      expiresAt: Date(timeIntervalSinceNow: TimeInterval(id.hashValue % 15 + 1) * 60),
                      location: GeoPoint(latitude: 0, longitude: 0),
                      destination: nil,
                      destinationName: nil,
                      destinationAddress: nil,
                      creator: User(id: "1", name: "Test", avatar: "---"))
    }
    
    func signalWithId(_ id: String) -> Signal {
        return Signal(id: id,
                      title: title,
                      text: text,
                      images: images,
                      manageImages: manageImages,
                      kind: kind,
                      type: type,
                      radius: radius,
                      kindDailyStart: kindDailyStart,
                      kindDailyDuration: kindDailyDuration,
                      createdAt: createdAt,
                      expiresAt: expiresAt,
                      location: location,
                      destination: destination,
                      destinationName: destinationName,
                      destinationAddress: destinationAddress,
                      creator: creator,
                      requests: requests)
    }
    
    func signalWithRequests(_ requests: [Request]?) -> Signal {
        return Signal(id: id,
                      title: title,
                      text: text,
                      images: images,
                      manageImages: manageImages,
                      kind: kind,
                      type: type,
                      radius: radius,
                      kindDailyStart: kindDailyStart,
                      kindDailyDuration: kindDailyDuration,
                      createdAt: createdAt,
                      expiresAt: expiresAt,
                      location: location,
                      destination: destination,
                      destinationName: destinationName,
                      destinationAddress: destinationAddress,
                      creator: creator,
                      requests: requests)
    }
    
    func signalWithImages(_ images: [Image], manageImages: Bool = true) -> Signal {
        return Signal(id: id,
                      title: title,
                      text: text,
                      images: images,
                      manageImages: manageImages,
                      kind: kind,
                      type: type,
                      radius: radius,
                      kindDailyStart: kindDailyStart,
                      kindDailyDuration: kindDailyDuration,
                      createdAt: createdAt,
                      expiresAt: expiresAt,
                      location: location,
                      destination: destination,
                      destinationName: destinationName,
                      destinationAddress: destinationAddress,
                      creator: creator,
                      requests: requests)
    }
    
    func signalWithLocationAndDestination(_ location: GeoPoint, _ destination: GeoPoint?) -> Signal {
        return Signal(id: id,
                      title: title,
                      text: text,
                      images: images,
                      manageImages: manageImages,
                      kind: kind,
                      type: type,
                      radius: radius,
                      kindDailyStart: kindDailyStart,
                      kindDailyDuration: kindDailyDuration,
                      createdAt: createdAt,
                      expiresAt: expiresAt,
                      location: location,
                      destination: destination,
                      destinationName: destinationName,
                      destinationAddress: destinationAddress,
                      creator: creator,
                      requests: requests)
    }
    
    func allExpired() -> Bool {
        return finalExpiration() < Date()
    }
    
    func finalExpiration() -> Date {
        var expiration = expiresAt
        
        if let myRequest = myRequest() {
            return myRequest.expiresAt
        }
        
        if isMine() {
            for request in requests ?? [] {
                if request.expiresAt > expiration {
                    expiration = request.expiresAt
                }
            }
        }
        
        return expiration
    }
    
    func isMine() -> Bool {
        return creator.isMe()
    }
    
    func haveRequested() -> Bool {
        if isMine() {
            return (requests ?? []).count > 0
        } else {
            return myRequest() != nil
        }
    }
    
    func wasAccepted() -> Bool {
        if isMine() {
            return acceptedRequest() != nil
        } else {
            return myRequest()?.accepted == true
        }
    }
    
    func wasRejected() -> Bool {
        if isMine() {
            return false
        } else {
            return myRequest()?.accepted == false
        }
    }
    
    func myRequest() -> Request? {
        return request(for: ProfileService.shared.profile?.id ?? "")
    }
    
    func request(for userId: String) -> Request? {
        return requests?.first { $0.sender.id == userId }
    }
    
    func acceptedRequest() -> Request? {
        return requests?.first { $0.accepted == true }
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Signal, rhs: Signal) -> Bool {
        return lhs.id == rhs.id
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                json.removeValue(forKey: "requests")
                json.removeValue(forKey: "location")
                json.removeValue(forKey: "destination")
                
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> Signal? {
        
        let location: GeoPoint? = json["location"] as? GeoPoint
        let destination: GeoPoint? = json["destination"] as? GeoPoint
        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "location")
        rectifiedJson.removeValue(forKey: "destination")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            var signal = try? JSONDecoder().decode(Signal.self, from: jsonData) {

            if let location = location {
                signal = signal.signalWithLocationAndDestination(location, destination)
            }
            
            return signal.signalWithImages(signal.images.sorted(by: { (lhs, rhs) -> Bool in
                lhs.order > rhs.order
            }))
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Signal? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Signal.fromJson(json)
        }
        return nil
    }
}

extension Signal {
    static let claimableDefaultRadius: Double = 1500

    func claimableInRange() -> Bool {
        let radius = self.radius ?? Signal.claimableDefaultRadius
        
        if let location = LocationService.shared.currentLocation, let myLocation = self.location {
            let signalLocation = CLLocation(latitude: myLocation.latitude, longitude: myLocation.longitude)
            return signalLocation.distance(from: location) <= radius
        }
        
        return false
    }
    
    func claimableActive() -> Bool {
        let now = Date()
        if createdAt <= now && now <= expiresAt {
            if let start = kindDailyStart,
                let duration = kindDailyDuration {
                let dailyStart = Calendar.current.startOfDay(for: now).addingTimeInterval(start)
                let dailyEnd = dailyStart.addingTimeInterval(duration)
                return dailyStart <= now && now <= dailyEnd
            } else {
                return true
            }
        }
        return false
    }
    
}
