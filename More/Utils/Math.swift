//
//  Math.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * CGFloat(Double.pi) / 180.0
    }
    func toDegrees() -> CGFloat {
        return self * 180 / CGFloat(Double.pi)
    }
}

extension Float {
    func toRadians() -> Float {
        return self * Float(Double.pi) / 180.0
    }
    func toDegrees() -> Float {
        return self * 180 / Float(Double.pi)
    }
}

extension Double {
    func toRadians() -> Double {
        return self * Double.pi / 180.0
    }
    func toDegrees() -> Double {
        return self * 180 / Double.pi
    }
}

extension CLLocationDistance {
    func metersToFeet() -> CLLocationDistance {
        return self * 3.28084
    }
    func feetToMeters() -> CLLocationDistance {
        return self / 3.28084
    }
    func metersToMiles() -> CLLocationDistance {
        return self * 0.000621371
    }
}

extension TimeInterval {
    func toMinutes() -> TimeInterval {
        return self / 60
    }
    func feetHours() -> TimeInterval {
        return self / 3600
    }
}


extension Double {
    func precised(_ value: Int = 1) -> Double {
        let offset = pow(10, Double(value))
        return (self * offset).rounded() / offset
    }
    
    static func equal(_ lhs: Double, _ rhs: Double, precise value: Int? = nil) -> Bool {
        guard let value = value else {
            return lhs == rhs
        }
        
        return lhs.precised(value) == rhs.precised(value)
    }
}

// MARK: - geometry

func pointInsidePolygon(point: GeoPoint, polygon: [GeoPoint]) -> Bool {
    
    if polygon.count < 3 {
        return false
    }
    
    var inside = false
    for i in 0..<polygon.count {
        let j = (i + 1) % polygon.count
        
        if ((polygon[i].longitude > point.longitude) != (polygon[j].longitude > point.longitude)) &&
            (point.latitude < (polygon[j].latitude - polygon[i].latitude) * (point.longitude - polygon[i].longitude) / (polygon[j].longitude - polygon[i].longitude) + polygon[i].latitude)
        {
            inside = !inside
        }
        
        /*
        if ((polygon[i].latitude! <= point.latitude! && point.latitude! < polygon[j].latitude!) || (polygon[j].latitude! <= point.latitude! && point.latitude! < polygon[i].latitude!))
            &&
            (point.longitude! < (polygon[j].longitude! - polygon[i].longitude!) * (point.latitude! - polygon[i].latitude!) / (polygon[j].latitude! - polygon[i].latitude!) + polygon[i].longitude!)
        {
            inside = !inside
        }
        */
    }
    return inside
}

func distance(point: GeoPoint, lineStart: GeoPoint, lineEnd: GeoPoint) -> Double {
    
    let A = point.latitude - lineStart.latitude
    let B = point.longitude - lineStart.longitude
    let C = lineEnd.latitude - lineStart.latitude
    let D = lineEnd.longitude - lineStart.longitude
    
    let dot = A * C + B * D
    let len_sq = C * C + D * D
    var param = Double(-1)
    if len_sq != 0 {
        param = dot / len_sq
    }
    
    var xx = lineStart.latitude
    var yy = lineStart.longitude
    
    if param >= 1 {
        xx = lineEnd.latitude
        yy = lineEnd.longitude
    } else if param > 0 {
        xx = xx + param * C
        yy = yy + param * D
    }
    return point.location().distance(from: CLLocation(latitude: xx, longitude: yy))
}

func distance(point: GeoPoint, polygon: [GeoPoint]) -> Double {
    
    if polygon.count == 0 {
        return Double.greatestFiniteMagnitude
    }
    
    if polygon.count == 1 {
        return point.location().distance(from: polygon[0].location())
    }
    
    if polygon.count == 2 {
        return distance(point: point, lineStart: polygon[0], lineEnd: polygon[1])
    }
    
    if pointInsidePolygon(point: point, polygon: polygon) {
        return 0
    }
    
    var minDistance = Double.greatestFiniteMagnitude
    for i in 0..<polygon.count {
        let j = (i + 1) % polygon.count
     
        let dist = distance(point: point, lineStart: polygon[i], lineEnd: polygon[j])
        if dist < minDistance {
            minDistance = dist
        }
    }
    return minDistance
}


struct Math {
    static let mileInMeters: Double = 1609.34
    static let kmInMeters: Double = 1000
}
