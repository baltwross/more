//
//  Window.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

enum WindowType: String, Codable {
    case circle, polygon
}

struct Window : MoreDataObject {
    
    let id: String
    let name: String
    let start: Date?
    let end: Date?
    let type: WindowType?
    let points: [GeoPoint]?
    let radius: Double?
    let buffer: Double?
    let mapCenter: GeoPoint?
    let mapRadius: Double?
    let shortName: String?
    
    init(id: String,
        name: String,
        start: Date? = nil,
        end: Date? = nil,
        type: WindowType? = nil,
        points: [GeoPoint]? = nil,
        radius: Double? = nil,
        buffer: Double? = nil,
        mapCenter: GeoPoint? = nil,
        mapRadius: Double? = nil,
        shortName: String? = nil) {
        
        self.id = id
        self.name = name
        self.start = start
        self.end = end
        self.type = type
        self.points = points
        self.radius = radius
        self.buffer = buffer
        self.mapCenter = mapCenter
        self.mapRadius = mapRadius
        self.shortName = shortName
    }
    
    init() {
        self.init(id: "", name: "")
    }
    
    func isInsideRegion(_ point: GeoPoint) -> Bool {
        guard let myLocation = LocationService.shared.currentLocation else { return false }
        
        if let type = type {
            if type == .circle {
                if let center = points?.first, let radius = radius {
                    return center.location().distance(from: myLocation) <= radius
                }
                return false
            }
            else if type == .polygon {
                if let points = points {
                    return distance(point: GeoPoint(coordinates: myLocation.coordinate), polygon: points) <= 0
                }
                return false
            }
        }
        return true
    }
    
    func isInsideRegionBuffer(_ point: GeoPoint) -> Bool {
        guard let myLocation = LocationService.shared.currentLocation else { return false }
        
        if let type = type {
            if type == .circle {
                if let center = points?.first, let radius = radius, let buffer = buffer {
                    let dist = center.location().distance(from: myLocation)
                    return dist > radius && dist <= buffer
                }
                return false
            }
            else if type == .polygon {
                if let points = points, let buffer = buffer {
                    let dist = distance(point: GeoPoint(coordinates: myLocation.coordinate), polygon: points)
                    return dist > 0 && dist <= buffer
                }
                return false
            }
        }
        return true
    }
    
    func isInsideTime() -> Bool {
        let now = Date()
        if let start = start {
            if start > now {
                return false
            }
        }
        if let end = end {
            if end < now {
                return false
            }
        }
        return true
    }
    
    func isExpired() -> Bool {
        let now = Date()
        if let end = end {
            if end < now {
                return true
            }
        }
        return false
    }
    
    func distanceTo() -> Double {
        guard let myLocation = LocationService.shared.currentLocation else { return Double.greatestFiniteMagnitude }
        
        if let type = type {
            if type == .circle {
                if let center = points?.first, let radius = radius {
                    return center.location().distance(from: myLocation) - radius
                }
                return Double.greatestFiniteMagnitude
            }
            else if type == .polygon {
                if let points = points {
                    return distance(point: GeoPoint(coordinates: myLocation.coordinate), polygon: points)
                }
                return Double.greatestFiniteMagnitude
            }
        }
        return 0
    }
    
    func timeDistanceTo() -> TimeInterval {
        if isExpired() {
            return TimeInterval.greatestFiniteMagnitude
        }
        if let start = start {
            return max(0, start.timeIntervalSinceNow)
        }
        return 0
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Window, rhs: Window) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Data protocol
    
    var json: [String : Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> Window? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let user = try? JSONDecoder().decode(Window.self, from: jsonData) {
            return user
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Window? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Window.fromJson(json)
        }
        return nil
    }

}
