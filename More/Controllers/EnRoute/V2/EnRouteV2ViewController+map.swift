//
//  EnRouteV2ViewController+map.swift
//  More
//
//  Created by Luko Gjenero on 17/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import MapKit
import Mapbox
import Firebase

class EnRouteV2ViewMapController: NSObject, MGLMapViewDelegate {

    private var time: ExperienceTime?
    private let mapBox: MGLMapView
    
    private var myLocation: GeoPoint? = nil
    private var myHeading: Double? = nil
    private var otherLocations: [String: GeoPoint] = [:]
    private var otherHeadings: [String: Double] = [:]
    private var otherDistances: [String: Double] = [:]
    private var meetLocation: GeoPoint? = nil
    private var meetName: String? = nil
    private var meetAddress: String? = nil

    private var initialSetup: Bool = true
    
    private var meetPin: MorePointAnnotation? = nil
    private var otherPins: [String: MorePointAnnotation] = [:]
    private var otherPinViews: [String: MorePointAnnotationView] = [:]
    
    init(mapBox: MGLMapView) {
        self.mapBox = mapBox
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(timeLocation(_:)), name: TimesService.Notifications.TimeLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate(_:)), name: LocationService.Notifications.LocationUpdate, object: nil)
        
        mapBox.styleURL = URL(string: MapBox.enrouteStyleUrl)
        mapBox.isPitchEnabled = false
        mapBox.delegate = self
        mapBox.showsUserLocation = true
        mapBox.compassView.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func timeLocation(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let time = notice.userInfo?["time"] as? ExperienceTime, time.id == self?.time?.id {
                self?.updateLocations()
            }
        }
    }
    
    
    @objc private func locationUpdate(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let location = LocationService.shared.currentLocation {
                self?.myLocation = GeoPoint(coordinates: location.coordinate)
                self?.updateMap()
            }
        }
    }
    
    func setupMap(for time: ExperienceTime) {
        self.time = time
        
        if let current = LocationService.shared.currentLocation {
            myLocation = GeoPoint(coordinates: current.coordinate)
        }
        let myId = ProfileService.shared.profile?.id ?? "--"
        if let locations = time.locations?.filter({ (item) -> Bool in return item.0 != myId}) {
            otherLocations = locations
        }
        if let location = time.meeting {
            meetLocation = location
        }
        updateMap()
    }
    
    func reset() {
        setupForAll()
    }
    
    private func updateLocations() {
        
        if let location = LocationService.shared.currentLocation {
            myLocation = location.geopointValue()
            if let heading = LocationService.shared.currentHeading {
                myHeading = heading.trueHeading
            } else {
                myHeading = 0
            }
        }
        
        guard let time = TimesService.shared.getActiveTime(), time.id == self.time?.id else { return }
        
        let myId = ProfileService.shared.profile?.id ?? "--"
        let newLocations = time.locations?.filter { key, _ in key != myId } ?? [:]
        for (userId, location) in newLocations {
            if let old = otherLocations[userId], !old.equalTo(location) {
                otherHeadings[userId] = old.coordinates().heading(to: old.coordinates())
            }
        }
        otherLocations = newLocations
        updateForOthers()
    }
    
    private var mapNeedsSetup = true
    private func updateMap() {
        guard mapBox.style != nil else { mapNeedsSetup = true; return }
        guard myLocation != nil else { return }
        
        if initialSetup {
            initialSetup = false
            updateForOthers()
            updateForMeet()
            setupForAll()
        }
    }
    
    private func setupForAll() {
        guard let me = myLocation else { return }
        
        // fit all inside the map
        var coordinates: [CLLocationCoordinate2D] = []
        coordinates.append(me.coordinates())
        if let meet = meetLocation {
            coordinates.append(meet.coordinates())
        }
        coordinates.append(contentsOf: otherLocations.values.map { $0.coordinates() })
        
        // init camera
        let camera = mapBox.camera
        camera.heading = 0
        mapBox.setCamera(camera, withDuration: 0.2, animationTimingFunction: nil, completionHandler: { [weak self] in
            self?.mapBox.setVisibleCoordinates(&coordinates, count: UInt(coordinates.count), edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20), animated: true)
        })
    }
    
    private func updateForOthers() {
        guard let time = time else { return }
        guard let chat = ChatService.shared.getChat(for: time.chat.memberIds) else { return }
        
        // add + update
        for (userId, location) in otherLocations {
            if otherPins[userId] == nil {
                let otherPin = MorePointAnnotation()
                otherPin.title = chat.member(id: userId)?.name ?? "Other"
                otherPin.image = UIImage(named: "other_pin")
                otherPin.reuseIdentifier = userId
                otherPin.user = chat.member(id: userId)
                otherPin.type = time.post.experience.type
                otherPins[userId] = otherPin
                mapBox.addAnnotations([otherPin])
            }

            guard let otherPin = otherPins[userId] else { continue }
                
            otherPin.coordinate = location.coordinates()
            if let heading = otherHeadings[userId] {
                otherPin.heading = heading
            }
            otherPinViews[userId]?.setup(for: otherPin)
        }
        
        // remove
        let removedPins = otherPins.filter { key, value in otherLocations[key] == nil }
        mapBox.removeAnnotations(Array(removedPins.values))
        removedPins.keys.forEach { otherPins.removeValue(forKey: $0) }
    }
    
    private func updateForMeet() {
        guard let meet = meetLocation else { return }
        if meetPin == nil {
            meetPin = MorePointAnnotation()
            meetPin?.title = meetName
            meetPin?.subtitle = meetAddress
            meetPin?.image = UIImage(named: "meet_pin")
            meetPin?.reuseIdentifier = "meet"
            mapBox.addAnnotations([meetPin!])
        }
        meetPin?.coordinate = meet.coordinates()
    }
    
    // MARK: - mapbox
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if mapNeedsSetup {
            updateMap()
        }
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        if let point = annotation as? MGLUserLocation {
            let reuseIdentifier = "me"
            
            var annotationView: MoreUserAnnotationView?
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MoreUserAnnotationView {
                annotationView = view
            } else {
                annotationView = MoreUserAnnotationView(annotation: point, reuseIdentifier: reuseIdentifier)
            }
            annotationView?.setup(for: UIImage(named: "me_pin")!)
            return annotationView
        }
        if let point = annotation as? MorePointAnnotation,
            let reuseIdentifier = point.reuseIdentifier {
            
            if reuseIdentifier == "meet" {
                var annotationView: MoreMeetPointAnnotationView!
                if let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MoreMeetPointAnnotationView {
                    annotationView = view
                } else {
                    annotationView = MoreMeetPointAnnotationView(annotation: point, reuseIdentifier: reuseIdentifier)
                }
                annotationView.setup(for: meetName?.uppercased() ?? "Meet point")
                return annotationView
            } else {
                var annotationView: MorePointAnnotationView!
                if let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MorePointAnnotationView {
                    annotationView = view
                    annotationView?.mapView = mapView
                } else {
                    annotationView = MorePointAnnotationView(annotation: point, reuseIdentifier: reuseIdentifier)
                }
                annotationView.mapView = mapView
                annotationView.setup(for: point)
                otherPinViews[reuseIdentifier] = annotationView
                return annotationView
            }
        }
        return nil
    }
    
//    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        if let point = annotation as? MorePointAnnotation,
//            let image = point.image,
//            let reuseIdentifier = point.reuseIdentifier,
//            reuseIdentifier == "meet" {
//
//            if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
//                return annotationImage
//            } else {
//                let alignedImage = image.imageWithAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height, right: 0))!
//                return MGLAnnotationImage(image: alignedImage, reuseIdentifier: reuseIdentifier)
//            }
//        }
//        return nil
//    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        // TODO: - ??
    }

    func mapView(_ mapView: MGLMapView, regionDidChangeWith reason: MGLCameraChangeReason, animated: Bool) {
        // TODO: - ??
    }
    
    // callouts
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        if annotation is MGLUserLocation {
            return true
        }
        
        if let point = annotation as? MorePointAnnotation,
            let reuseIdentifier = point.reuseIdentifier,
            reuseIdentifier != "meet" {
            return true
        }
        
        return false
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        if annotation is MGLUserLocation {
            let callout = EnRouteUserCalloutView()
            callout.setupForMe(time?.post.experience.type ?? .chill)
            return callout
        }
        
        if let point = annotation as? MorePointAnnotation,
            let reuseIdentifier = point.reuseIdentifier,
            reuseIdentifier != "meet" {
            let callout = EnRouteUserCalloutView()
            callout.representedObject = point
            return callout
        }
        
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        // Hide the callout.
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
}

