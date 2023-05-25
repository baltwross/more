//
//  CreateSignalPlaceViewController.swift
//  More
//
//  Created by Luko Gjenero on 07/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Mapbox
import Firebase

class CreateSignalPlaceViewController: UIViewController, MGLMapViewDelegate {

    @IBOutlet private weak var selectorContainer: UIView!
    @IBOutlet private weak var selector: CreateSignalPlaceSelectorView!
    
    @IBOutlet private weak var panelContainer: UIView!
    @IBOutlet private weak var panel: CreateSignalPlaceSearchPanel!
    @IBOutlet private weak var panelContainerTop: NSLayoutConstraint!
    
    @IBOutlet private weak var mapView: MGLMapView!
    
    private var location: GeoPoint?
    private var name: String?
    private var address: String?
    private var locationPin: MorePointAnnotation? = nil
    
    private var neighbourhood: String?
    private var city: String?
    private var state: String?
    
    private var mapViewHeight: CGFloat = 0
    
    var back: (()->())?
    var selected: ((_ location: GeoPoint?, _ name: String?, _ address: String?, _ neighbourhood: String?, _ city: String?, _ state: String?)->())?
    var reset: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.enableShadow(color: .black)
        
        selectorContainer.layer.cornerRadius = 12
        selectorContainer.layer.masksToBounds = true
        
        selector.close = { [weak self] in
            self?.back?()
        }
        
        selector.done = { [weak self] in
            self?.selected?(self?.location, self?.name, self?.address, self?.neighbourhood, self?.city, self?.state)
        }
        
        selector.anywhere = { [weak self] in
            self?.location = nil
            self?.name = nil
            self?.address = nil
            self?.updateDoneButton()
        }
        
        selector.somewhere = { [weak self] in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self?.setupPanelLayout()
                    self?.view.layoutIfNeeded()
                })
        }
        
        panelContainer.layer.cornerRadius = 12
        panelContainer.layer.masksToBounds = true
        
        panel.backTap = { [ weak self] in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self?.setupSelectorLayout()
                    self?.view.layoutIfNeeded()
                })
        }
        
        panel.doneTap = { [ weak self] in
            if let location = self?.location,
                let name = self?.name,
                let address = self?.address {
                
                self?.selected?(location, name, address, self?.neighbourhood, self?.city, self?.state)
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
        
        panel.suggestionSelected = { [weak self] suggestion in
            
            guard let location = suggestion.location else { return }
            
            self?.updateLocation(location, suggestion.name, suggestion.address, suggestion.neighbourhood, suggestion.city, suggestion.state)
            self?.updateDoneButton()
        }
        

        setupSelectorLayout()
        setupMapView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if mapViewHeight != mapView.frame.height {
           mapViewHeight = mapView.frame.height
            panelContainerTop.constant = mapViewHeight - 16
        }
    }
    
    func setup(location: GeoPoint, name: String, address: String, neighbourhood: String?, city: String?, state: String?) {
        updateLocation(location, name, address, neighbourhood, city, state)
        selector.selection = .somewhere
        updateDoneButton()
        setupPanelLayout()
    }
    
    func setupForAnywhere() {
        selector.selection = .anywhere
        updateDoneButton()
    }
    
    // MARK: - actions
    
    private func updateLocation(_ place: PlacesSearchService.PlaceData) {
        let location = GeoPoint(coordinates: place.location)
        let nameLower = place.name.lowercased()
        if nameLower == place.neighbourhood {
            updateLocation(location, place.name, place.address, place.neighbourhood, nil, nil)
        } else if nameLower == place.city {
            updateLocation(location, place.name, place.address, nil, place.city, nil)
        } else if nameLower == place.state {
            updateLocation(location, place.name, place.address, nil, nil, place.state)
        } else {
            updateLocation(location, place.name, place.address, nil, nil, nil)
        }
    }
    
    private func updateLocation(_ location: GeoPoint, _ name: String, _ address: String, _ neighbourhood: String?, _ city: String?, _ state: String?) {
        self.location = location
        self.name = name
        self.address = address
        self.neighbourhood = neighbourhood?.lowercased()
        self.city = city?.lowercased()
        self.state = state?.lowercased()
        updateMapLocation()
    }
    
    private func updateDoneButton() {
        switch selector.selection {
        case .anywhere:
            selector.doneIsHidden = false
            panel.doneIsHidden = true
        case .somewhere:
            selector.doneIsHidden = location == nil
            panel.doneIsHidden = location == nil
        default:
            selector.doneIsHidden = true
            panel.doneIsHidden = true
        }
    }
    
    // MARK: UI
    
    private func setupSelectorLayout() {
        selectorContainer.alpha = 1
        selectorContainer.layer.transform = CATransform3DIdentity
        
        mapView.alpha = 0
        mapView.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.height, 0)
        
        panelContainer.alpha = 0
        panelContainer.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.height, 0)
    }
    
    private func setupPanelLayout() {
        selectorContainer.alpha = 0
        selectorContainer.layer.transform = CATransform3DMakeTranslation(0, 300, 0)
        
        mapView.alpha = 1
        mapView.layer.transform = CATransform3DIdentity
        
        panelContainer.alpha = 1
        panelContainer.layer.transform = CATransform3DIdentity
    }
    
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
                self?.updateLocation(GeoPoint(coordinates: place.location), place.name, place.address, nil, nil, nil)
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

