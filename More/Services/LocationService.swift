//
//  LocationService.swift
//  geoFireTut
//
//  Created by Anirudh Bandi on 6/25/18.
//  Copyright © 2018 More Technologies. All rights reserved.
//


import CoreLocation
import Foundation
import Firebase

class LocationService: NSObject, CLLocationManagerDelegate {

    struct Notifications {
        static let LocationUpdate = NSNotification.Name(rawValue: "com.more.location.update")
        static let LocationDescription = NSNotification.Name(rawValue: "com.more.location.description")
        static let LocationDescriptionUpdate = NSNotification.Name(rawValue: "com.more.location.description.update")
        static let LocationError = NSNotification.Name(rawValue: "com.more.location.error")
        static let LocationPermissionChange = NSNotification.Name(rawValue: "com.more.location.premission")
    }
    
    static var locationEnabled: Bool {
        get {
            if !CLLocationManager.locationServicesEnabled() {
                return false
            }
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                return true
            default:
                return false
            }
        }
    }
    
    static var canRequestLocation: Bool {
        get {
            if !CLLocationManager.locationServicesEnabled() {
                return false
            }
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                return true
            default:
                return false
            }
        }
    }
    
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()

    private(set) var currentLocation: CLLocation?
    private(set) var currentHeading: CLHeading?
    
    private(set) var  neighbourhood: String = ""
    private(set) var  city: String = ""
    private(set) var  state: String = ""
    
    private override init() {
        super.init()
        
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .fitness
        locationManager.delegate = self
        
        if LocationService.locationEnabled {
            if UIApplication.shared.applicationState == .background {
                locationManager.startMonitoringSignificantLocationChanges()
            }
            locationManager.startUpdatingLocation()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func toForeground() {
        if LocationService.locationEnabled {
            locationManager.startUpdatingLocation()
        }
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    @objc private func toBackground() {
        if stopUpdatesIfNotNeeded() {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    @discardableResult
    private func stopUpdatesIfNotNeeded() -> Bool {
        var disable = true
        if let time = TimesService.shared.getActiveTime() {
            if !time.isFinished() {
                disable = false
            }
        }
        
        if disable {
            for experience in ExperienceTrackingService.shared.getActiveExperiences() {
                if let post = experience.myPost(), post.expiresAt.timeIntervalSinceNow > 0 {
                    disable = false
                    break
                }
                if let request = experience.myRequest(),
                    let post = experience.post(for: request.id), post.expiresAt.timeIntervalSinceNow > 0 {
                    disable = false
                    break
                }
            }
        }
        
        if disable {
            locationManager.stopUpdatingLocation()
        }
        
        return disable
    }
    
    func requestAlways() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func requestWhenInUse() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        NotificationCenter.default.post(name: Notifications.LocationPermissionChange, object: self, userInfo: ["premission": status])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationCenter.default.post(name: Notifications.LocationError, object: self, userInfo: ["error": error])
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        currentLocation = location
        
        updateLocationDescription(location)
        
        NotificationCenter.default.post(name: Notifications.LocationUpdate, object: self, userInfo: ["location": location])
        
        if UIApplication.shared.applicationState == .background {
            stopUpdatesIfNotNeeded()
        }
    }
    
    // MARK: - reverse geo coding
    
    private func updateLocationDescription(_ location: CLLocation) {
        GeoService.shared.getPlace(for: location) { [weak self] (place, _) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let place = place {
                    var notify = false
                    
                    if self.neighbourhood != place.neighbourhood {
                        self.neighbourhood = place.neighbourhood
                        notify = true
                    }
                    if self.city != place.city {
                        self.city = place.city
                        notify = true
                    }
                    if self.state != place.state {
                        self.state = place.state
                        notify = true
                    }
                    
                    if notify {
                        NotificationCenter.default.post(name: Notifications.LocationDescriptionUpdate, object: self, userInfo: ["location": location, "neighbourhood": place.neighbourhood, "city": place.city, "state": place.state])
                    }
                }
                NotificationCenter.default.post(name: Notifications.LocationDescription, object: self, userInfo: ["location": location, "neighbourhood": self.neighbourhood, "city": self.city, "state": self.state])
            }
        }
    }
}
