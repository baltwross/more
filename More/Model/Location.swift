//
//  Location.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//


import Firebase
import CoreLocation

protocol CodableGeoPoint: Codable {
    var latitude: Double { get }
    var longitude: Double { get }
    
    init(latitude: Double, longitude: Double)
}

enum CodableGeoPointCodingKeys: CodingKey {
    case latitude, longitude
}

extension CodableGeoPoint {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodableGeoPointCodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodableGeoPointCodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

extension GeoPoint: CodableGeoPoint {
    
    convenience init(coordinates: CLLocationCoordinate2D) {
        self.init(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    public func location() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func coordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func center(between otherLocation: GeoPoint) -> GeoPoint {
        let lat = (latitude + otherLocation.latitude) * 0.5
        let lon = (longitude + otherLocation.longitude) * 0.5
        return GeoPoint(latitude: lat, longitude: lon)
    }
    
    func equalTo(_ other: GeoPoint) -> Bool {
        return Double.equal(latitude, other.latitude, precise: 5) &&
            Double.equal(longitude, other.longitude, precise: 5)
    }
}

extension CLLocationCoordinate2D {
    public func location() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    public func geoPoint() -> GeoPoint {
        return GeoPoint(coordinates: self)
    }
}

extension CLLocation {
    public func geoPoint() -> GeoPoint {
        return GeoPoint(coordinates: coordinate)
    }
}

/*
class MoreGeoPoint: GeoPoint, Codable {
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        super.init(
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude))
    }
    
    override init(latitude: Double, longitude: Double) {
        super.init(latitude: latitude, longitude: longitude)
    }
    
    init(coordinates: CLLocationCoordinate2D) {
        super.init(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public func location() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func coordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func center(between otherLocation: MoreGeoPoint) -> MoreGeoPoint {
        let lat = (latitude + otherLocation.latitude) * 0.5
        let lon = (longitude + otherLocation.longitude) * 0.5
        return MoreGeoPoint(latitude: lat, longitude: lon)
    }
}
*/

/*
struct Location: MoreDataObject {
    
    let id: String = ""
    var point: GeoPoint? = nil
    var name: String? = nil
    var address: String? = nil
    
    init(point: GeoPoint?,
         name: String? = nil,
         address: String? = nil) {
        self.point = point
        self.name = name
        self.address = address
    }
    
    init(coordinates: CLLocationCoordinate2D,
         name: String? = nil,
         address: String? = nil) {
        self.point = GeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
        self.name = name
        self.address = address
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(point?.latitude ?? 0)
        hasher.combine(point?.longitude ?? 0)
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        return Double.equal(lhs.point?.latitude ?? 0, rhs.point?.latitude ?? 0, precise: 5) &&
            Double.equal(lhs.point?.longitude ?? 0, rhs.point?.longitude ?? 0, precise: 5)
    }
    
    // Data protocol
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                return json
            }
            return nil
        }
        set {
            guard let newValue = newValue else { return }
            if let jsonData = try? JSONSerialization.data(withJSONObject: newValue, options: []),
                let location = try? JSONDecoder().decode(Location.self, from: jsonData) {
                
                self.point = location.point
                self.name = location.name
                self.address = location.address
            }
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> Location? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let location = try? JSONDecoder().decode(Location.self, from: jsonData) {
            return location
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Location? {
        if let json = snapshot.data() {
            return Location.fromJson(json)
        }
        return nil
    }
    
    func coordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: point?.latitude ?? 0, longitude: point?.longitude ?? 0)
    }
    
    func location() -> CLLocation {
        return CLLocation(latitude: point?.latitude ?? 0, longitude: point?.longitude ?? 0)
    }
    
    func center(between otherLocation: Location) -> Location {
        let lat = ((point?.latitude ?? 0) + (otherLocation.point?.latitude ?? 0)) * 0.5
        let lon = ((point?.longitude ?? 0) + (otherLocation.point?.longitude ?? 0)) * 0.5
        return GeoPoint(point: GeoPoint(latitude: lat, longitude: lon))
    }
}

*/
