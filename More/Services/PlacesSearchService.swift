//
//  PlacesSearchService.swift
//  More
//
//  Created by Luko Gjenero on 28/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import MapKit
import CoreLocation

extension CLLocationCoordinate2D: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    
    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return Double.equal(lhs.latitude, rhs.latitude, precise: 5) &&
            Double.equal(lhs.longitude, rhs.longitude, precise: 5)
    }
}

class PlacesSearchService {

    struct PlaceData: Hashable {
        
        let location: CLLocationCoordinate2D
        let name: String
        let address: String
        let neighbourhood: String
        let city: String
        let state: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(location)
        }
        
        static func == (lhs: PlaceData, rhs: PlaceData) -> Bool {
            return lhs.location == rhs.location
        }
    }
    
    static let shared = PlacesSearchService()
    
    init() {
        // TODO: - setup
    }
    
    func search(for searchString:  String, complete: @escaping (_ results: [PlaceData])->()) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchString
        
        // US
        let centerOfUS = CLLocationCoordinate2D(latitude: 39.999733, longitude: -98.678503)
        let spanOfUS = MKCoordinateSpan(latitudeDelta: 13.589921, longitudeDelta:14.062500)
        var region = MKCoordinateRegion(center: centerOfUS, span: spanOfUS)
        
        // Near you
        if let myLocation = LocationService.shared.currentLocation {
            region = MKCoordinateRegion(center: myLocation.coordinate, latitudinalMeters: Math.mileInMeters * 2, longitudinalMeters: Math.mileInMeters * 2)
        }
        
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            let results: [PlaceData] = response.mapItems.map({ (mapItem) -> PlaceData in
                return PlaceData(
                    location: mapItem.placemark.coordinate,
                    name: mapItem.placemark.nameOfPlace,
                    address: mapItem.placemark.address,
                    neighbourhood: mapItem.placemark.neighbourhood.lowercased(),
                    city: mapItem.placemark.city.lowercased(),
                    state: mapItem.placemark.state.lowercased())
            })
            
            complete(results)
        }
    }
    
    
}

private extension MKPlacemark {
    var address: String {
        var addressString = ""
        if subThoroughfare != nil {
            addressString = subThoroughfare! + " "
        }
        if thoroughfare != nil {
            addressString = addressString + thoroughfare! + ", "
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
        /*
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
        if !neighbourhood.isEmpty && neighbourhood.lowercased() != name?.lowercased() {
            nameString = nameString + ", " + neighbourhood
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
