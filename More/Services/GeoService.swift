//
//  GeoService.swift
//  More
//
//  Created by Luko Gjenero on 14/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections
import CoreLocation
import MapboxGeocoder
import Firebase
import FirebaseFirestore
import FirebaseFunctions

class GeoService {
    
    static let shared = GeoService()
    
    private let geoCoder = CLGeocoder()
    
    func getDistanceAndETA(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, complete: ((_ distanceInMeters: Double?, _ time: TimeInterval?, _ errorMsg: String?)->())?) {
        
        getRoute(from: from, to: to) { (route, errorMsg) in
            if let route = route {
                complete?(route.distance, route.expectedTravelTime, nil)
            } else {
                complete?(nil, nil, errorMsg ?? "Unknown error")
            }
        }
    }
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, labels: [String]? = nil, includeSteps: Bool = true, complete: ((_ route: Route?,  _ errorMsg: String?)->())?) {
        
        let fromLabel = labels?.first ?? "From"
        let toLabel = (labels?.count ?? 0) >= 2 ? labels![1] : "To"
        
        let waypoints = [
            Waypoint(coordinate: from, name: fromLabel),
            Waypoint(coordinate: to, name: toLabel),
            ]
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: .walking)
        options.routeShapeResolution = .full
        options.includesSteps = includeSteps
        options.includesAlternativeRoutes = false
        
        Directions.shared.calculate(options) { (session, result) in // waypoints, routes, error) in
            switch result {
            case .success(let response):
                if let route = response.routes?.first {
                    complete?(route, nil)
                } else {
                    complete?(nil, "No routes found")
                }
            case .failure(let error):
                complete?(nil, error.localizedDescription)
            }
        }
    }
    
    func getMidpoint(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, complete: ((_ location: GeoPoint?, _ errorMsg: String?)->())?) {
        
        getRoute(from: from, to: to, includeSteps: false) { (route, errorMsg) in
            if let route = route {
                
                var travelled: CLLocationDistance = 0
                let midpoint: CLLocationDistance = route.distance * 0.5
                
                if let coords = route.shape?.coordinates {
                    
                    if coords.count > 1 {
                        var point = coords[0]
                        
                        for coordinate in coords.suffix(from: 1) {
                            
                            let start = CLLocation(latitude: point.latitude, longitude: point.longitude)
                            let end = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            
                            let distance = start.distance(from: end)
                            
                            if travelled + distance > midpoint {
                                
                                let delta = midpoint - travelled
                                let fragment = delta / distance
                                let latitudeDelta = coordinate.latitude - point.latitude
                                let longitudeDelta = coordinate.longitude - point.longitude
                                
                                let location = GeoPoint(
                                    latitude: point.latitude + latitudeDelta * fragment,
                                    longitude: point.longitude + longitudeDelta * fragment)
                                
                                complete?(location, nil)
                                return
                            }
                            
                            travelled += distance
                            point = coordinate
                        }
                    } else {
                        complete?(GeoPoint(coordinates: coords[0]), nil)
                        return
                    }
                } else {
                    // WTF?.
                }
                
                complete?(nil, "No midpoint")
                
            } else {
                complete?(nil, errorMsg)
            }
        }
    }
    
    func getPlace(for location: CLLocation, complete: ((_ place: PlacesSearchService.PlaceData?, _ errorMsg: String?)->())?) {
        
        let options = ReverseGeocodeOptions(coordinate: location.coordinate)
        
        Geocoder.shared.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else {
                complete?(nil, error?.localizedDescription)
                return
            }
            
            let place =  PlacesSearchService.PlaceData(
                location: (placemark.location ?? location).coordinate,
                name: placemark.name,
                address: placemark.shortAddress,
                neighbourhood: placemark.neighborhood?.name.lowercased() ?? "",
                city: placemark.place?.name.lowercased() ?? "",
                state: placemark.administrativeRegion?.name.lowercased() ?? "")
            complete?(place, nil)
        }
        
        /*
        geoCoder.reverseGeocodeLocation(location) { (marks, error) in
            if let mark = marks?.first {
                let place =  PlacesSearchService.PlaceData(
                    location: (mark.location ?? location).coordinate,
                    name: mark.nameOfPlace,
                    address: mark.address,
                    neighbourhood: mark.neighbourhood)
                complete?(place, nil)
            } else {
                complete?(nil, error?.localizedDescription)
            }
        }
        */
    }
    
    func getDistance(from: String, to: String, complete: ((_ distanceInMeters: Double)->())?) {
        Functions.functions().httpsCallable("getDistance")
            .call(["from": from, "to": to]) { (result, _) in
                if let data = result?.data as? [String: Any],
                    let distance = data["distance"] as? Double {
                    complete?(distance)
                }
        }
    }
    
    func getPostMeetPoint(post: ExperiencePost, complete: ((_ point: GeoPoint)->())?) {
        Functions.functions().httpsCallable("getPostMeetingPoint")
            .call(["experienceId": post.experience.id, "postId": post.id]) { (result, _) in
                if let data = result?.data as? [String: Any],
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double {
                    complete?(GeoPoint(latitude: latitude, longitude: longitude))
                }
        }
    }
    
    func getRequestMeetPoint(request: ExperienceRequest, complete: ((_ point: GeoPoint)->())?) {
        Functions.functions().httpsCallable("getRequestMeetingPoint")
            .call(["experienceId": request.post.experience.id, "postId": request.post.id, "requestId": request.id]) { (result, _) in
                if let data = result?.data as? [String: Any],
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double {
                    complete?(GeoPoint(latitude: latitude, longitude: longitude))
                }
        }
    }
    
}

private extension Placemark {
    var shortAddress: String {
        var addressString = ""
        
        if let lines = addressDictionary?["formattedAddressLines"] as? [String] {
            addressString = lines.joined(separator: ", ")
        } else {
            if subThoroughfare != nil {
                addressString = subThoroughfare! + " "
            }
            if thoroughfare != nil {
                addressString = addressString + thoroughfare!
            }
        }
        
        /*
        if subThoroughfare != nil {
            addressString = subThoroughfare! + " "
        }
        if thoroughfare != nil {
            addressString = addressString + thoroughfare! // + ", "
        }
        if postalCode != nil {
            addressString = addressString + postalCode! + " "
        }
        if locality != nil {
            addressString = addressString + locality! + ", "
        }
        if administrativeArea != nil {
            addressString = addressString + administrativeArea! + " "
        }
        if country != nil {
            addressString = addressString + placemark.country!
        }
        */
        return addressString
    }

}

private extension CLPlacemark {
    var address: String {
        var addressString = ""
        if let subThoroughfare = subThoroughfare {
            addressString = subThoroughfare + " "
        }
        if let thoroughfare = thoroughfare {
            addressString = addressString + thoroughfare // + ", "
        }
        /*
        if postalCode != nil {
            addressString = addressString + postalCode! + " "
        }
        if locality != nil {
            addressString = addressString + locality! + ", "
        }
        if administrativeArea != nil {
            addressString = addressString + administrativeArea! + " "
        }
        if country != nil {
            addressString = addressString + placemark.country!
        }
        */
        return addressString
    }
    
    var nameOfPlace: String {
        var nameString = ""
        if let name = name {
            nameString = name
        }
        if let first = areasOfInterest?.first {
            nameString = nameString + ", " + first
        }
        return nameString
    }
    
    var neighbourhood: String {
        var neighbourhoodString = ""
        if let subLocality = subLocality {
            neighbourhoodString = subLocality
        }
        return neighbourhoodString
    }
    
    var city: String {
        var cityString = ""
        if let locality = locality {
            cityString = locality
        }
        return cityString
    }
    
    var state: String {
        var stateString = ""
        if let administrativeArea = administrativeArea {
            stateString = administrativeArea
        }
        return stateString
    }
    
}
