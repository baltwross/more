//
//  CoreLocation+utils.swift
//  More
//
//  Created by Luko Gjenero on 09/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    
    func move(latitudeDelta: Double, longitudeDelta: Double) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude + latitudeDelta, longitude: longitude + longitudeDelta)
    }
    
    func heading(to coordinate: CLLocationCoordinate2D) -> Double {
        
        let lat = latitude.toRadians()
        let lon = longitude.toRadians()
        
        let toLat = coordinate.latitude.toRadians()
        let toLon = coordinate.longitude.toRadians()
        
        let heading = atan2(sin(toLon - lon)*cos(toLat), cos(lat)*sin(toLat) - sin(lat)*cos(toLat)*cos(toLon - lon)).toDegrees()
            
        if heading >= 0 {
            return heading
        }
        return 360 + heading
    }
}

