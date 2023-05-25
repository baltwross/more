//
//  SignalDetailsMapCell.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import MapKit
import Mapbox
import Firebase
import FirebaseFirestore

class SignalDetailsMapCell: SignalDetailsBaseCell, MGLMapViewDelegate {

    private static let fullSize: CGFloat = 488
    private static let fullSizeMapPadding: CGFloat = 228
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var nearby: SignalJourneyItemView!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var destination: SignalJourneyItemView!
    @IBOutlet private weak var mapBox: MGLMapView!
    @IBOutlet private weak var shadow: FadeView!
    @IBOutlet private weak var mapPadding: NSLayoutConstraint!
    
    private var annotationTitle: String? = nil
    private var annotationText: String? = nil
    private var location: GeoPoint? = nil
    private var addPinTolocation: Bool = false
    private var locationRadius: Double = 0
    private var animating: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadow.orientation = .up
        shadow.color = UIColor.black.withAlphaComponent(0.1)
        
        mapBox.showsUserLocation = true
        mapBox.delegate = self
        mapBox.styleURL = URL(string: MapBox.styleUrl)
    }
    
    // MARK: - experience details view
    
    override class func isShowing(for experience: Experience) -> Bool {
        return !(experience.isVirtual ?? false)
    }
    
    override func setup(for experience: Experience) {
        title.text = "Your Journey"
        
        nearby.setup(for: experience)
        destination.setup(for: experience)
        
        setupJourneyBlock(for: experience)
        setupMapBlock(for: experience)
    }
    
    // MARK: journey block
    
    private func setupJourneyBlock(for experience: Experience) {
        if experience.anywhere == true {
            // anywhere
            showDestination()
        } else if experience.neighbourhood == nil &&
            experience.city == nil &&
            experience.state == nil {
            if let destination = experience.destination,
                let post = experience.activePost(), post.meeting?.equalTo(destination) == true {
                showDestination()
            } else {
                showDestination()
            }
        } else {
            // neighbourhood, city or state
            hideDestination()
        }
    }
    
    private func hideDestination() {
        destination.isHidden = true
        separator.isHidden = true
        mapPadding.constant = SignalDetailsMapCell.fullSizeMapPadding - 82
        nearby.bottomConnectionHidden = true
        destination.topConnectionHidden = true
    }
    
    private func showDestination() {
        self.destination.isHidden = false
        separator.isHidden = false
        mapPadding.constant = SignalDetailsMapCell.fullSizeMapPadding
        nearby.bottomConnectionHidden = false
        destination.topConnectionHidden = false
    }
    
    // MARK: map data
    
    private func setupMapBlock(for experience: Experience) {
        if experience.anywhere == true {
            // anywhere
            if let post = experience.activePost(), let location = post.location {
                if let meeting = post.meeting {
                    var radius: Double = 1000
                    if let myLocation = LocationService.shared.currentLocation {
                        radius = meeting.location().distance(from: myLocation) * 1.2
                    }
                    radius = max(400, radius)
                    setupMap(at: meeting.coordinates(), radius: radius, pin: true, title: post.meetingAddress, text: post.meetingName ?? "")
                } else {
                    var radius: Double = 400
                    if let chat = post.chat, chat.memberIds.count > 2 {
                        radius = 1000
                    }
                    setupMap(at: location.coordinates(), radius: radius)
                }
            } else if let location = LocationService.shared.currentLocation {
                setupMap(at: location.coordinate, radius: 400, text: "Choose specific meeting point after connecting")
            }
        } else if experience.neighbourhood == nil &&
            experience.city == nil &&
            experience.state == nil {
            // destination
            if let post = experience.activePost(), let location = post.location {
                if let meeting = post.meeting {
                    var radius: Double = 1000
                    if let myLocation = LocationService.shared.currentLocation {
                        radius = meeting.location().distance(from: myLocation) * 1.2
                    }
                    radius = max(400, radius)
                    setupMap(at: meeting.coordinates(), radius: radius, pin: true, title: post.meetingAddress, text: post.meetingName ?? "")
                } else {
                    var radius: Double = 400
                    if post.chat == nil, let myLocation = LocationService.shared.currentLocation {
                        radius = location.location().distance(from: myLocation) * 1.2
                    }
                    radius = max(400, radius)
                    let place = experience.destinationName ?? ""
                    setupMap(at: location.coordinates(), radius: radius, title: "Near \(place)")
                }
            } else if let location = experience.destination {
                var radius: Double = 400
                if let myLocation = LocationService.shared.currentLocation {
                    radius = max(400, location.location().distance(from: myLocation) * 1.2)
                }
                let place = experience.destinationName ?? ""
                setupMap(at: location.coordinates(), radius: radius, title: "Near \(place)", text: "Choose specific meeting point after connecting")
            }
        } else {
            // neighbourhood, city or state
            if let post = experience.activePost(), let location = post.location {
                if let meeting = post.meeting {
                    var radius: Double = 1000
                    if let myLocation = LocationService.shared.currentLocation {
                        radius = meeting.location().distance(from: myLocation) * 1.2
                    }
                    radius = max(400, radius)
                    setupMap(at: meeting.coordinates(), radius: radius, pin: true, title: post.meetingAddress, text: post.meetingName ?? "")
                } else {
                    var radius: Double = 1000
                    if post.chat == nil, let myLocation = LocationService.shared.currentLocation {
                        radius = min(2000, location.location().distance(from: myLocation) * 1.2)
                    }
                    radius = max(400, radius)
                    let place = (experience.neighbourhood ?? experience.city ?? experience.state)?.capitalized ?? ""
                    setupMap(at: location.coordinates(), radius: radius, title: place)
                }
            } else if let location = experience.destination {
                let place = (experience.neighbourhood ?? experience.city ?? experience.state)?.capitalized ?? ""
                setupMap(at: location.coordinates(), radius: 2000, title: place, text: "Choose specific meeting point after connecting")
            }
        }
    }
    
    // MARK: - experience preview
    
    override func setup(for model: CreateExperienceViewModel) {
        title.text = "Your Journey"
        
        nearby.type = SignalJourneyItemView.ItemType.nearby.rawValue
        nearby.setup(for: model)
        
        destination.setup(for: model)
        
        if model.destination != nil &&
            model.destinationNeighbourhood == nil &&
            model.destinationCity == nil &&
            model.destinationState == nil {
            self.destination.isHidden = false
            mapPadding.constant = SignalDetailsMapCell.fullSizeMapPadding
            nearby.bottomConnectionHidden = false
            destination.topConnectionHidden = false
        } else {
            destination.isHidden = true
            mapPadding.constant = SignalDetailsMapCell.fullSizeMapPadding - 82
            nearby.bottomConnectionHidden = true
            destination.topConnectionHidden = true
        }
        
        // map
        if let location = model.destination {
            setupMap(at: location.coordinates(), radius: 2000)
        }
    }
    
    override class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        if model.somewhere {
            return false
        }
        return true
    }
    
    // MARK: - map
    
    private func setupMap(at location: CLLocationCoordinate2D,
                          radius: Double,
                          pin: Bool = false,
                          title: String? = nil,
                          text: String = "Exact location revealed after connecting") {
    
        setupMapLocation(at: location, radius: radius, pin: pin)
        
        if let title = title {
            annotationTitle = title
        }
        annotationText = text
        
        if title != nil {
            addAnnotation(pin: pin)
            return
        }
        
        GeoService.shared.getPlace(for: CLLocation(latitude: location.latitude, longitude: location.longitude)) { [weak self] (place, _) in
            DispatchQueue.main.async {
                if let place = place {
                    self?.annotationTitle = place.neighbourhood.capitalized
                } else {
                    self?.annotationTitle = "Somewhere"
                }
                self?.addAnnotation(pin: pin)
            }
        }
    }
    
    private func setupMapLocation(at location: CLLocationCoordinate2D, radius: Double, pin: Bool) {
        if let old = mapBox.annotations, old.count > 0 {
            mapBox.removeAnnotations(old)
        }
        
        animating = mapBox.style != nil
        let camera = MGLMapCamera(lookingAtCenter: location, altitude: radius * 1.5, pitch: 75, heading: 0)
        if animating {
            mapBox.fly(to: camera) { [weak self] in
                self?.animating = false
                self?.addAnnotation(pin: pin)
            }
        } else {
            mapBox.setCamera(camera, animated: false)
            addAnnotation(pin: pin)
        }
        
        let location = GeoPoint(coordinates: location)
        self.location = location
        self.locationRadius = radius
        if pin {
            self.addPinTolocation = true
        } else {
            addArea(at: location, radius: radius)
            self.addPinTolocation = false
        }
    }
    
    private var areaAdded = false
    
    private func addArea(at location: GeoPoint, radius: Double) {
        guard !areaAdded else { return }
        guard let style = mapBox.style else { return }
        
        areaAdded = true
        
        let areaRegion = MKCoordinateRegion(center: location.coordinates(), latitudinalMeters: radius, longitudinalMeters: radius)
        
        var area: MGLImageSource!
        if let existingArea = style.source(withIdentifier: "more-area") as? MGLImageSource {
            existingArea.coordinates = areaRegion.mapBoxQuad
            area = existingArea
        } else {
            area = MGLImageSource(identifier: "more-area", coordinateQuad: areaRegion.mapBoxQuad, image: UIImage(named: "location_area")!)
            style.addSource(area)
        }
        
        // Create a raster layer from the MGLImageSource.
        if let areaLayer = style.layer(withIdentifier: "more-area-layer") {
            style.removeLayer(areaLayer)
        }
        let areaLayer = MGLRasterStyleLayer(identifier: "more-area-layer", source: area)
        
        // Insert the image below the map's symbol layers.
        for layer in style.layers.reversed() {
            if !layer.isKind(of: MGLSymbolStyleLayer.self) {
                style.insertLayer(areaLayer, above: layer)
                break
            }
        }
    }
    
    // private var annotationAdded = false
    
    private func addAnnotation(pin: Bool) {
        guard !animating else { return }
        // guard !annotationAdded else { return }
        guard let location = location, let title = annotationTitle, let text = annotationText else { return }
        guard mapBox.style != nil else { return }
        
        // annotationAdded = true
        
        mapBox.removeAnnotations(mapBox.annotations ?? [])
        
        // Annotation
        let coordinates = location.coordinates()
        let areaRegion = MKCoordinateRegion(center: location.coordinates(), latitudinalMeters: Math.mileInMeters * 0.5, longitudinalMeters: Math.mileInMeters * 0.5)
        let point = MorePointAnnotation()
        point.coordinate = coordinates.move(latitudeDelta: areaRegion.span.latitudeDelta * 0.33, longitudeDelta: 0)
        point.title = title
        point.subtitle = text
        point.image = pin ? UIImage(named: "meet_pin") : nil
        point.reuseIdentifier = "center"
        if let old = mapBox.annotations, old.count > 0 {
            mapBox.removeAnnotations(old)
        }
        mapBox.addAnnotations([point])
        mapBox.selectAnnotation(point, animated: true, completionHandler: nil)
    }
    
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if let location = location {
            if !addPinTolocation {
                addArea(at: location, radius: locationRadius)
            }
            addAnnotation(pin: addPinTolocation)
        }
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        guard let moreAnnotation = annotation as? MorePointAnnotation else { return nil }
        guard moreAnnotation.image == nil else { return nil }
        
        let reuseIdentifier = "reusableDotView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            annotationView?.layer.borderColor = UIColor.clear.cgColor
            annotationView?.backgroundColor = .clear
        }
    
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let point = annotation as? MorePointAnnotation,
            let image = point.image,
            let reuseIdentifier = point.reuseIdentifier {
            
            if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
                return annotationImage
            } else {
                let alignedImage = image.imageWithAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height, right: 0))!
                return MGLAnnotationImage(image: alignedImage, reuseIdentifier: reuseIdentifier)
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        let callout = MoreCalloutView()
        callout.representedObject = annotation
        return callout
    }
    
}
