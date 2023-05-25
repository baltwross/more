//
//  ChatMeetingSelectorViewController.swift
//  
//
//  Created by Luko Gjenero on 13/12/2019.
//

import UIKit
import Mapbox
import Firebase

class ChatMeetingSelectorViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet private weak var panelContainer: UIView!
    @IBOutlet private weak var panel: ChatMeetingSearchPanel!
    @IBOutlet private weak var panelContainerTop: NSLayoutConstraint!
    
    @IBOutlet private weak var mapView: MGLMapView!
    
    private var location: GeoPoint?
    private var name: String?
    private var address: String?
    private var type: MeetType?
    private var locationPin: MorePointAnnotation? = nil
    
    private var post: ExperiencePost?
    private var request: ExperienceRequest?
    
    private var mapViewHeight: CGFloat = 0
    
    var back: (()->())?
    var selected: ((_ location: GeoPoint?, _ name: String?, _ address: String?, _ type: MeetType?)->())?
    var reset: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.enableShadow(color: .black)
        
        panelContainer.layer.cornerRadius = 12
        panelContainer.layer.masksToBounds = true
        
        panel.backTap = { [ weak self] in
            self?.back?()
        }
        
        panel.doneTap = { [ weak self] in
            if let location = self?.location,
                let name = self?.name,
                let address = self?.address {
                
                self?.selected?(location, name, address, self?.type)
            }
        }
        
        panel.placeSelected = { [weak self] place in
            
            self?.panel.reset()
            self?.panel.closeKeyboard()
            
            self?.updateLocation(place)
            self?.updateDoneButton()
            self?.panel.resetSuggestion()
        }
        
        panel.searchFocus = { [weak self] inFocus in
            UIView.animate(
            withDuration: 0.3,
            animations: {
                self?.setupPanelSearchLayout(inFocus)
                self?.view.layoutIfNeeded()
            })
        }
        
        panel.suggestionSelected = { [weak self] place, type in
            self?.updateLocation(place, type)
            self?.updateDoneButton()
        }
        
        setupMapView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if mapViewHeight != mapView.frame.height {
           mapViewHeight = mapView.frame.height
            panelContainerTop.constant = mapViewHeight - 16
        }
    }
    
    func setup(post: ExperiencePost, request: ExperienceRequest?, location: GeoPoint?, name: String?, address: String?, type: MeetType?) {
        self.post = post
        self.request = request
        updateLocation(location, name, address, type)
    }
    
    func setupForNone() {
        updateDoneButton()
    }
    
    // MARK: - actions
    
    private func updateLocation(_ place: PlacesSearchService.PlaceData, _ type: MeetType? = nil) {
        updateLocation(GeoPoint(coordinates: place.location), place.name, place.address, type)
    }
    
    private func updateLocation(_ location: GeoPoint?, _ name: String?, _ address: String?, _ type: MeetType?) {
        self.location = location
        self.name = name
        self.address = address
        self.type = type
        panel.setup(post: post,  request: request, type: type)
        updateMapLocation()
        updateDoneButton()
    }
    
    private func updateDoneButton() {
        panel.doneIsHidden = self.location == nil
    }
    
    // MARK: UI
    
    private func setupPanelSearchLayout(_ search: Bool) {
        panelContainerTop.constant = search ? 0 : (mapView.frame.height - 16)
    }

    // MARK: - map
    
    private func setupMapView() {
        mapView.styleURL = URL(string: MapBox.styleUrl)
        mapView.isPitchEnabled = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.compassView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapTap(_:)))
        mapView.addGestureRecognizer(tap)
    }
    
    private func updateMapLocation() {
        guard let location = location else { return }
        updateMapLocation(to: location.coordinates(), completion: { [weak self] in
            self?.updateLocation()
        })
    }
    
    private func updateMapLocation(to location: CLLocationCoordinate2D, completion: (()->())? = nil) {
        let camera = MGLMapCamera(
            lookingAtCenter: location,
            altitude: Math.mileInMeters * 2,
            pitch: 0,
            heading: 0)
        mapView.setCamera(camera, withDuration: 0.3, animationTimingFunction: nil, completionHandler: completion)
    }
    
    private func updateLocation() {
        if let location = location {
            if locationPin == nil {
                locationPin = MorePointAnnotation()
                
                locationPin?.image = UIImage(named: "meet_pin")
                locationPin?.reuseIdentifier = "location"
                mapView.addAnnotations([locationPin!])
            }
            locationPin?.title = name
            locationPin?.subtitle = address
            locationPin?.coordinate = location.coordinates()
            mapView.selectAnnotation(locationPin!, animated: false, completionHandler: nil)
        } else {
            guard let locationPin = locationPin else { return }
            mapView.removeAnnotation(locationPin)
        }
    }
    
    @objc private func mapTap(_ gesture: UITapGestureRecognizer) {
        let viewLocation = gesture.location(in: mapView)
        let coordinate = mapView.convert(viewLocation, toCoordinateFrom: mapView)
        let location = GeoPoint(coordinates: coordinate)
        
        GeoService.shared.getPlace(for: location.locationValue()) { [weak self] (place, _) in
            if let place = place {
                self?.updateLocation(GeoPoint(coordinates: place.location), place.name, place.address, nil)
                self?.updateDoneButton()
                self?.panel.resetSuggestion()
            }
        }
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        if mapNeedsSetup {
            updateMap()
        }
    }
    
    private var mapNeedsSetup = true
    private func updateMap() {
        guard mapView.style != nil else { mapNeedsSetup = true; return }

        if location != nil {
            updateMapLocation()
        } else if let me = mapView.userLocation {
            updateMapLocation(to: me.coordinate)
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
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let point = annotation as? MorePointAnnotation,
            let image = point.image,
            let reuseIdentifier = point.reuseIdentifier,
            reuseIdentifier == "location" {
            
            if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
                return annotationImage
            } else {
                let alignedImage = image.imageWithAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height, right: 0))!
                return MGLAnnotationImage(image: alignedImage, reuseIdentifier: reuseIdentifier)
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if mapNeedsSetup {
            updateMap()
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, calloutViewFor annotation: MGLAnnotation) -> MGLCalloutView? {
        if annotation as? MorePointAnnotation == locationPin {
            let callout = CreateSignalPlaceCallout()
            callout.representedObject = annotation
            return callout
        }
        return nil
    }

}
