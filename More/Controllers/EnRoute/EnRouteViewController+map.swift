//
//  EnRouteViewController+map.swift
//  More
//
//  Created by Luko Gjenero on 19/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import MapKit
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import Firebase

private let myPolyLine = "my_polyline"
private let otherPolyline = "other_polyline"

class EnRouteViewMapController: NSObject, MGLMapViewDelegate, NavigationServiceDelegate {

    private var time: ExperienceTime?
    private let mapBox: MGLMapView
    private let tableViewHeader: EnRouteMessagingHeader
    private let destinationView: EnRouteDestinationView
    private let directionsView: EnRouteDirectionsView
    
    private var myLocation: GeoPoint? = nil
    private var otherLocations: [String: GeoPoint] = [:]
    private var otherDistances: [String: Double] = [:]
    private var meetLocation: GeoPoint? = nil
    private var meetName: String? = nil
    private var meetAddress: String? = nil

    private var otherHeading: Double? = nil
    
    private var initialSetupForMe: Bool = true
    private var initialSetupForBoth: Bool = true
    
    private var otherPin: MorePointAnnotation? = nil
    private var meetPin: MorePointAnnotation? = nil
    private var otherPinView: MorePointAnnotationView? = nil
    
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var routeLine: MGLPolyline? = nil
    private var navigationService: MapboxNavigationService? = nil
    private var otherRouteLine: MGLPolyline? = nil
    
    private var isBirdEye = false
    
    var bottomPading: CGFloat = 0 {
        didSet {
            guard oldValue != bottomPading else { return }
            if isBirdEye {
                birdEyeView(true)
            }
        }
    }
    
    var birdEye: (()->())?
    
    weak var initialNotice: EnRouteNotice? {
        didSet {
            updateInitial()
        }
    }
    
    init(mapBox: MGLMapView, tableViewHeader: EnRouteMessagingHeader, destinationView: EnRouteDestinationView, directionsView: EnRouteDirectionsView) {
        self.mapBox = mapBox
        self.tableViewHeader = tableViewHeader
        self.destinationView = destinationView
        self.directionsView = directionsView
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(timeLocation(_:)), name: TimesService.Notifications.TimeLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timeState(_:)), name: TimesService.Notifications.TimeStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationTest(_:)), name: LocationService.Notifications.LocationTest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate(_:)), name: LocationService.Notifications.LocationUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        destinationView.isHidden = true
        directionsView.isHidden = true
        destinationView.expand(animated: false)
        mapBox.isPitchEnabled = false
        mapBox.delegate = self
        mapBox.showsUserLocation = true
        mapBox.compassView.isHidden = true
        
        startTracking()
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
    
    @objc private func timeState(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let time = notice.userInfo?["time"] as? ExperienceTime, time.id == self?.time?.id {
                self?.updateStates()
            }
        }
    }
    
    @objc private func toForeground(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let me = self?.myLocation {
                self?.updateForMe(me)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            if LocationService.shared.testLocation {
                self?.mapBox.locationManager.stopUpdatingLocation()
                if let location = LocationService.shared.currentLocation {
                    if let locationManager = self?.mapBox.locationManager {
                        locationManager.delegate?.locationManager(locationManager, didUpdate: [location])
                    }
                }
            }
        }
    }
    
    @objc private func locationTest(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.mapBox.locationManager.stopUpdatingLocation()
        }
    }
    
    @objc private func locationUpdate(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let location = LocationService.shared.currentLocation {
                self?.myLocation = GeoPoint(coordinates: location.coordinate)
                self?.updateMap()
                
                if LocationService.shared.testLocation {
                    if let locationManager = self?.mapBox.locationManager {
                        locationManager.delegate?.locationManager(locationManager, didUpdate: [location])
                    }
                }
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
    
    func trackUser(root: UIViewController? = nil) {
        if let me = myLocation {
            setupForMe(me)
            directionsView.isHidden = routeLine == nil
            destinationView.isHidden = routeLine == nil
        }
    }
    
    private func updateInitial() {
        guard let time = time else { return }
        guard let route = navigationService?.route else { return }
        let title = time.isMine() ? "You Accepted \(time.requester.name)'s Request!" : "\(time.signal.creator.name) Accepted Your Request!"
        let minutes = Int(route.expectedTravelTime /  60)
        var minuteText = "\(minutes) minutes"
        if minutes < 1 {
            minuteText = "less than 1 minute"
        } else if minutes == 1 {
            minuteText = "1 minute"
        }
        let text = "Meet \(time.isMine() ? time.requester.name : time.signal.creator.name) in \(minuteText) at the meeting point."
        initialNotice?.setup(title: title, text: text)
    }
    
    private func updateLocations() {
        
    }
    
    private func updateStates() {
        
    }
    
    private var mapNeedsSetup = true
    private func updateMap() {
        guard mapBox.style != nil else { mapNeedsSetup = true; return }
        guard let me = myLocation else { return }
        
        if let other = otherLocation {
            if initialSetupForBoth {
                initialSetupForBoth = false
                setupForBoth(me, other)
            }
            updateForBoth(me, other)
        } else {
            if initialSetupForMe {
                initialSetupForMe = false
                setupForMe(me)
            }
            updateForMe(me)
        }
    }
    
    private func setupForBoth(_ me: GeoPoint, _ other: GeoPoint) {
        
        // init camera
        var coordinates = [me.coordinates(), other.coordinates()]
        mapBox.setVisibleCoordinates(&coordinates, count: 2, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
    }
    
    private func updateForBoth(_ me: GeoPoint, _ other: GeoPoint) {
        
        if let meet = meetLocation {
            reRouteIfNeeded()
            GeoService.shared.getRoute(from: other.coordinates(), to: meet.coordinates(), includeSteps: false) { [weak self] (route, errorMsg) in
                if let route = route {
                    route.routeOptions.routeShapeResolution = .full
                    if let coordinates = route.coordinates, coordinates.count > 0 {
                        self?.updateOtherRoute(with: coordinates)
                    }
                }
            }
        } else {
            GeoService.shared.getMidpoint(from: me.coordinates(), to: other.coordinates()) { [weak self] (meet, errorMsg) in
                if let meet = meet {
                    self?.findMidpointName(meet)
                }
            }
        }
    
        updateForMe(me)
        updateForOther(other)
    }
    
    private func findMidpointName(_ meet: GeoPoint) {
        
        GeoService.shared.getPlace(for: meet.location()) { [weak self] (place, _) in
            if let place = place {
                if let sself = self, sself.meetLocation == nil, let timeId = sself.time?.id {
                    let meet = GeoPoint(coordinates: meet.coordinates())
                    sself.meetLocation = meet
                    sself.meetName = place.name
                    sself.meetAddress = place.address
                    // TimesService.shared.updateTimeMeeting(timeId: timeId, location: meet)
                }
                self?.reRouteIfNeeded()
            }
        }
    }
    
    private func reRouteIfNeeded() {
        guard let me = myLocation, let meet = meetLocation else { return }
        
        if navigationService == nil {
            GeoService.shared.getRoute(from: me.coordinates(), to: meet.coordinates(), labels: ["From", meetName ?? "To"]) { [weak self] (route, errorMsg) in
                if let route = route, route.coordinateCount > 0 {
                    route.routeOptions.shapeFormat = .polyline6
                    route.routeOptions.routeShapeResolution = .full
                    let service = MapboxNavigationService(route: route) //, locationSource: DebugLocationManager(), routerType: RouteController.self)
                    service.delegate = self
                    service.simulationMode = .never
                    self?.navigationService = service
                    
                    self?.updateRoute(with: route.coordinates!)
                    service.start()
                    
                    self?.updateInitial()
                }
            }
        }
    
        updateForMeet(meet)
        updateForMe(me)
    }
    
    private func updateRoute(with coordinates: [CLLocationCoordinate2D]) {
        if let line = routeLine {
            updatePolyline(line, name: myPolyLine, for: coordinates)
            self.routeCoordinates = coordinates
        } else {
            if let routeLine = createPolyline(name: myPolyLine, for: coordinates) {
                self.routeLine = routeLine
                self.routeCoordinates = coordinates
            }
        }
    }
    
    private func updateOtherRoute(with coordinates: [CLLocationCoordinate2D]) {
        if let line = otherRouteLine {
            updatePolyline(line, name: otherPolyline, for: coordinates)
        } else {
            if let routeLine = createPolyline(name: otherPolyline, for: coordinates) {
                self.otherRouteLine = routeLine
            }
        }
    }
    
    private func setupForMe(_ me: GeoPoint) {
        mapBox.contentInset = UIEdgeInsets(top: mapBox.frame.height - 240, left: 0, bottom: 0, right: 0)
        let camera = MGLMapCamera(lookingAtCenter: me.coordinates(), altitude: Math.mileInMeters * 0.25, pitch: 0, heading: 0)
        mapBox.setCamera(camera, withDuration: 0.3, animationTimingFunction: nil) { [weak self] in
            self?.mapBox.setUserTrackingMode(.followWithHeading, animated: false, completionHandler: nil)
        }
        isBirdEye = false
    }
    
    private func updateForMe(_ me: GeoPoint) {
        // nothing
    }
    
    private func updateForOther(_ other: GeoPoint) {
        
        if otherPin == nil {
            otherPin = MorePointAnnotation()
            otherPin?.title = time?.otherPerson().name ?? "Other"
            otherPin?.image = UIImage(named: "other_pin")
            otherPin?.reuseIdentifier = "other"
            mapBox.addAnnotations([otherPin!])
        }
        otherPin?.coordinate = other.coordinates()
        if let heading = otherHeading {
            otherPin?.heading = heading
        }
        
        otherPinView?.setup(for: otherPin!)
    }
    
    private func updateForMeet(_ meet: GeoPoint) {
        
        var goBirdEye  = false
        if meetPin == nil {
            goBirdEye = true
            meetPin = MorePointAnnotation()
            meetPin?.title = meetName
            meetPin?.subtitle = meetAddress
            meetPin?.image = UIImage(named: "meet_pin")
            meetPin?.reuseIdentifier = "meet"
            mapBox.addAnnotations([meetPin!])
        }
        meetPin?.coordinate = meet.coordinates()
        
        // init camera
        if goBirdEye {
            birdEyeView()
        }
    }
    
    private func birdEyeView(_ animated: Bool = false) {
        guard let me = myLocation, let other = otherLocation, let meet = meetLocation else { return }
        var coordinates = [me.coordinates(), other.coordinates(), meet.coordinates()]
        
        isBirdEye = true
        mapBox.contentInset = .zero
        mapBox.setUserTrackingMode(.none, animated: false, completionHandler: nil)
        let camera = mapBox.camera
        camera.heading = me.coordinates().heading(to: other.coordinates())
        mapBox.setCamera(camera, animated: false)
        mapBox.setVisibleCoordinates(&coordinates, count: 3, edgePadding: UIEdgeInsets(top: 40, left: 20, bottom: 100 + bottomPading, right: 20), animated: animated)
    }
    
    private func createPolyline(name: String, for coordinates: [CLLocationCoordinate2D]) -> MGLPolyline? {
        
        guard let style = mapBox.style else { return nil }
    
        
        
        //////////////////////////
        // line
        
        var colors: [Float: UIColor] = [:]
        if name == myPolyLine {
            let (col1, col2, col3) = time?.signal.type.pathGradient ?? (UIColor.green, UIColor.red, UIColor.blue)
            colors = [0: col1, 0.5: col2, 1: col3]
        } else {
            colors = [0: UIColor(rgb: 0xc5ced8)]
        }
        
        var routeCoordinates = coordinates
        let polyLine = MGLPolyline(coordinates: &routeCoordinates, count: UInt(coordinates.count))
        
        let source = MGLShapeSource(identifier: name, shape: polyLine, options: [MGLShapeSourceOption.lineDistanceMetrics : true])
        style.addSource(source)
        
        // Create new layer for the line.
        let layer = MGLLineStyleLayer(identifier: name, source: source)
        
        // Set the line join and cap to a rounded end.
        layer.lineJoin = NSExpression(forConstantValue: "square")
        layer.lineCap = NSExpression(forConstantValue: "square")
        
        // Set the line color to a gradient,
        if colors.count > 1 {
            layer.lineGradient = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($lineProgress, 'linear', nil, %@)", colors)
        } else {
            layer.lineColor = NSExpression(forConstantValue: colors.first!.value)
        }
        
        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 4, 18: 7])
        
        //////////////////////////
        // dots
        
        var (outer, inner) = time?.signal.type.pathEnd ?? (UIColor.red, UIColor.blue)
        if name != myPolyLine {
            (outer, inner) = (UIColor(rgb: 0xb9c5d0), UIColor(rgb: 0x919fb0))
        }
        
        var dots: [CLLocationCoordinate2D] = []
        if coordinates.count > 0 {
            dots.append(coordinates.first!)
        }
        if coordinates.count > 1 {
            dots.append(coordinates.last!)
        }
        let dotsPolyline = MGLPolyline(coordinates: &dots, count: UInt(dots.count))
        let dotsSource = MGLShapeSource(identifier: "\(name)-dots", shape: dotsPolyline, options: nil)
        style.addSource(dotsSource)
        
        let dotsLayer = MGLCircleStyleLayer(identifier: "\(name)-dots", source: dotsSource)
        dotsLayer.circleColor = NSExpression(forConstantValue: inner)
        dotsLayer.circleRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                [14: 4, 18: 6])
        dotsLayer.circleStrokeWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                                     [14: 4, 18: 5])
        dotsLayer.circleStrokeColor = NSExpression(forConstantValue: outer)
     
        var roadIdentifier = "com.mapbox.annotations.points"
        for layer in style.layers.reversed() {
            roadIdentifier = layer.identifier
            if !(layer is MGLSymbolStyleLayer) {
                break
            }
        }
        
        if let annotationLayer = style.layer(withIdentifier: roadIdentifier) {
            if name == myPolyLine {
                if let otherLayer = style.layer(withIdentifier: "\(otherPolyline)-dots") {
                    style.insertLayer(dotsLayer, above: otherLayer)
                    style.insertLayer(layer, below: dotsLayer)
                } else {
                    style.insertLayer(dotsLayer, below: annotationLayer)
                    style.insertLayer(layer, below: dotsLayer)
                }
            } else {
                if let myLayer = style.layer(withIdentifier: "\(myPolyLine)") {
                    style.insertLayer(dotsLayer, below: myLayer)
                    style.insertLayer(layer, below: dotsLayer)
                } else {
                    style.insertLayer(dotsLayer, below: annotationLayer)
                    style.insertLayer(layer, below: dotsLayer)
                }
            }
        } else {
            style.addLayer(dotsLayer)
            style.insertLayer(layer, below: dotsLayer)
        }
        
        return polyLine
    }
    
    private func updatePolyline(_ line: MGLPolyline, name: String, for coordinates: [CLLocationCoordinate2D]) {
        
        guard let style = mapBox.style else { return }
        
        var routeCoordinates = coordinates
        line.setCoordinates(&routeCoordinates, count: UInt(coordinates.count))
        if let source = style.source(withIdentifier: name) as? MGLShapeSource {
            source.shape = line
        }
        if let source = style.source(withIdentifier: "\(name)-dots") as? MGLShapeSource {
            var dots: [CLLocationCoordinate2D] = []
            if coordinates.count > 0 {
                dots.append(coordinates.first!)
            }
            if coordinates.count > 1 {
                dots.append(coordinates.last!)
            }
            let dotsPolyline = MGLPolyline(coordinates: &dots, count: UInt(dots.count))
            source.shape = dotsPolyline
        }
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
            let reuseIdentifier = point.reuseIdentifier,
            reuseIdentifier == "other" {
            
            var annotationView: MorePointAnnotationView?
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MorePointAnnotationView {
                annotationView = view
                annotationView?.mapView = mapView
            } else {
                annotationView = MorePointAnnotationView(annotation: point, reuseIdentifier: reuseIdentifier)
            }
            annotationView?.mapView = mapView
            annotationView?.setup(for: point)
            otherPinView = annotationView
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let point = annotation as? MorePointAnnotation,
            let image = point.image,
            let reuseIdentifier = point.reuseIdentifier,
            reuseIdentifier == "meet" {
            
            if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
                return annotationImage
            } else {
                let alignedImage = image.imageWithAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height, right: 0))!
                return MGLAnnotationImage(image: alignedImage, reuseIdentifier: reuseIdentifier)
            }
        }
        return nil
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        if let other = otherPin {
            otherPinView?.setup(for: other)
        }
    }

    func mapView(_ mapView: MGLMapView, regionDidChangeWith reason: MGLCameraChangeReason, animated: Bool) {
        guard mapBox.userTrackingMode == .followWithHeading || !isBirdEye else { return }
        guard reason == .gesturePinch || reason == .gestureZoomOut || reason == .gestureOneFingerZoom else { return }
        
        if mapBox.camera.viewingDistance > Math.mileInMeters {
            birdEyeView(true)
            birdEye?()
            destinationView.isHidden = routeLine == nil
            directionsView.isHidden = routeLine == nil
            destinationView.expand(animated: false)
        }
    }
    
    func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        
        directionsView.setup(
            maneuver: progress.currentLegProgress.currentStep.maneuverType,
            direction: progress.currentLegProgress.currentStep.maneuverDirection,
            distance: progress.currentLegProgress.currentStepProgress.distanceRemaining,
            instructions: progress.currentLegProgress.currentStep.instructions)
        
        destinationView.setup(
            time: progress.durationRemaining,
            distance: progress.distanceRemaining,
            instructions: meetAddress ?? "Meetup")
        
        
        // updating the map
        var stepCoordinate: CLLocationCoordinate2D? = nil
        if let coordinates = progress.currentLegProgress.currentStep.coordinates, coordinates.count > 0 {
            if coordinates.count == 1 {
                stepCoordinate = coordinates[0]
            } else {
                let last = coordinates.last!
                let lastLocation = CLLocation(latitude: last.latitude, longitude: last.longitude)
                stepCoordinate = last
                var distance = location.distance(from: lastLocation)
                for coordinate in coordinates.suffix(from: 1) {
                    let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let dist = loc.distance(from: lastLocation)
                    if distance > dist {
                        distance = dist
                        stepCoordinate = coordinate
                        break
                    }
                }
            }
        }
        
        if let last = stepCoordinate {
            for (idx, coordinate) in routeCoordinates.enumerated() {
                if Double.equal(coordinate.latitude, last.latitude, precise: 5) &&
                    Double.equal(coordinate.longitude, last.longitude, precise: 5) {
                    var routeCoordinates = Array(self.routeCoordinates.suffix(from: idx))
                    routeCoordinates.insert(location.coordinate, at: 0)
                    if let line = routeLine {
                        updatePolyline(line, name: myPolyLine, for: routeCoordinates)
                    }
                    break
                }
            }
        }
    }
    
    func navigationService(_ service: NavigationService, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
        route.routeOptions.routeShapeResolution = .full
        updateRoute(with: route.coordinates!)
        
        if let step = route.legs.first?.steps.first {
            directionsView.setup(
                maneuver: step.maneuverType,
                direction: step.maneuverDirection,
                distance: step.distance,
                instructions: step.instructions)
            
            destinationView.setup(
                time: route.expectedTravelTime,
                distance: route.distance,
                instructions: meetAddress ?? "Meetup")
        } else {
            directionsView.isHidden = true
            destinationView.isHidden = true
        }
    }
    
}

extension EnRouteViewMapController {
    
    private func startTracking() {
        NotificationCenter.default.addObserver(self, selector: #selector(progressDidChange(_ :)), name: .routeControllerProgressDidChange, object: nil)
    }
    
    
    // Notifications sent on all location updates
    @objc private func progressDidChange(_ notification: NSNotification) {
        
        let routeProgress = notification.userInfo![RouteControllerNotificationUserInfoKey.routeProgressKey] as! RouteProgress
        let location = notification.userInfo![RouteControllerNotificationUserInfoKey.locationKey] as! CLLocation
        
        
        updateRouteProgress(progress: routeProgress, location: location)
        
        /*
        // Add maneuver arrow
        if routeProgress.currentLegProgress.followOnStep != nil {
            mapView.addArrow(route: routeProgress.route, legIndex: routeProgress.legIndex, stepIndex: routeProgress.currentLegProgress.stepIndex + 1)
        } else {
            mapView.removeArrow()
        }
        
        // Update the top banner with progress updates
        instructionsBannerView.updateDistance(for: routeProgress.currentLegProgress.currentStepProgress)
        instructionsBannerView.isHidden = false
        
        // Update the user puck
        mapView.updateCourseTracking(location: GeoPoint, animated: true)
        */
        
    }
    
    private func updateRouteProgress(progress: RouteProgress, location: CLLocation) {
        directionsView.setup(
            maneuver: progress.currentLegProgress.currentStep.maneuverType,
            direction: progress.currentLegProgress.currentStep.maneuverDirection,
            distance: progress.currentLegProgress.currentStepProgress.distanceRemaining,
            instructions: progress.currentLegProgress.currentStep.instructions)
        
        destinationView.setup(
            time: progress.durationRemaining,
            distance: progress.distanceRemaining,
            instructions: meetAddress ?? "Meetup")
        
        
        // updating the map
        var stepCoordinate: CLLocationCoordinate2D? = nil
        if let coordinates = progress.currentLegProgress.currentStep.coordinates, coordinates.count > 0 {
            if coordinates.count == 1 {
                stepCoordinate = coordinates[0]
            } else {
                let last = coordinates.last!
                let lastLocation = CLLocation(latitude: last.latitude, longitude: last.longitude)
                stepCoordinate = last
                var distance = location.distance(from: lastLocation)
                for coordinate in coordinates.suffix(from: 1) {
                    let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let dist = loc.distance(from: lastLocation)
                    if distance > dist {
                        distance = dist
                        stepCoordinate = coordinate
                        break
                    }
                }
            }
        }
        
        if let last = stepCoordinate {
            for (idx, coordinate) in routeCoordinates.enumerated() {
                if Double.equal(coordinate.latitude, last.latitude, precise: 5) &&
                    Double.equal(coordinate.longitude, last.longitude, precise: 5) {
                    var routeCoordinates = Array(self.routeCoordinates.suffix(from: idx))
                    routeCoordinates.insert(location.coordinate, at: 0)
                    if let line = routeLine {
                        updatePolyline(line, name: myPolyLine, for: routeCoordinates)
                    }
                    break
                }
            }
        }
    }
    
}
