//
//  MapKit+utils.swift
//  More
//
//  Created by Luko Gjenero on 09/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import MapKit
import CoreLocation
import Mapbox

extension MKCoordinateRegion {
    var southWest: CLLocationCoordinate2D {
        return center.move(latitudeDelta: -span.latitudeDelta * 0.5, longitudeDelta: -span.longitudeDelta * 0.5)
    }
    
    var southEast: CLLocationCoordinate2D {
        return center.move(latitudeDelta: -span.latitudeDelta * 0.5, longitudeDelta: span.longitudeDelta * 0.5)
    }
    
    var northWest: CLLocationCoordinate2D {
        return center.move(latitudeDelta: span.latitudeDelta * 0.5, longitudeDelta: -span.longitudeDelta * 0.5)
    }
    
    var northEast: CLLocationCoordinate2D {
        return center.move(latitudeDelta: span.latitudeDelta * 0.5, longitudeDelta: span.longitudeDelta * 0.5)
    }
    
    var mapBoxBounds: MGLCoordinateBounds {
        return MGLCoordinateBounds(sw: southWest, ne: northEast)
    }

    var mapBoxQuad: MGLCoordinateQuad {
        return MGLCoordinateQuad(topLeft: northWest, bottomLeft: southWest, bottomRight: southEast, topRight: northEast)
    }
}

class MorePointAnnotation: MGLPointAnnotation {
    var image: UIImage? = nil
    var reuseIdentifier: String? = nil
    var heading: Double? = nil
    var user: ShortUser? = nil
    var type: SignalType? = nil
}

class MoreUserPointAnnotation: MGLUserLocation {
    var image: UIImage? = nil
    var reuseIdentifier: String? = nil
    var user: ShortUser? = nil
    var type: SignalType? = nil
}

class MoreMeetPointAnnotation: MGLPointAnnotation {
    var image: UIImage? = nil
    var reuseIdentifier: String? = nil
    var user: ShortUser? = nil
    var type: SignalType? = nil
}

class MorePointAnnotationView: MGLAnnotationView {
    let size = CGSize(width: 44, height: 32)
    
    var mapView: MGLMapView!
    
    private let icon: CALayer = {
        let icon = CALayer()
        icon.backgroundColor = UIColor.clear.cgColor
        return icon
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        icon.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        layer.addSublayer(icon)
        setNeedsLayout()
    }
    
    func setup(for annotation: MorePointAnnotation) {
        if icon.contents == nil {
            icon.contents = annotation.image?.cgImage
        }
        if let heading = annotation.heading {
            update(heading: heading)
        }
        
    }
    
    func update(heading: Double) {
        let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)
        
        if abs(rotation) > 0.01 {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            icon.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
            CATransaction.commit()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.contents = nil
    }
}


class MoreUserAnnotationView: MGLUserLocationAnnotationView {
    let size = CGSize(width: 67, height: 65)
    
    private let icon: CALayer = {
        let icon = CALayer()
        icon.backgroundColor = UIColor.clear.cgColor
        return icon
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        icon.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        layer.addSublayer(icon)
        setNeedsLayout()
    }
    
    func setup(for image: UIImage) {
        icon.contents = image.cgImage
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.contents = nil
    }

    override func update() {
        
        // Check whether we have the user’s location yet.
        if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
            updateHeading()
        }
    }
    
    private func updateHeading() {
        if let heading = userLocation!.heading?.trueHeading {
            let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)
            
            if abs(rotation) > 0.01 {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                icon.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
                CATransaction.commit()
            }
        }
    }
}

class MoreMeetPointAnnotationView: MGLAnnotationView {
    let size = CGSize(width: 132, height: 61)
    
    private let icon: CALayer = {
        let icon = CALayer()
        icon.backgroundColor = UIColor.whiteThree.cgColor
        icon.cornerRadius = 22.5
        icon.contentsGravity = .center
        icon.contentsScale = UIScreen.main.scale
        icon.contents = UIImage(named: "meet-pin-grey")?.cgImage
        icon.enableShadow(color: .black)
        return icon
    }()
    
    private let bubble: CAShapeLayer = {
        let bubble = CAShapeLayer()
        bubble.backgroundColor = UIColor.clear.cgColor
        bubble.fillColor = UIColor.black.cgColor
        bubble.enableShadow(color: .black)
        return bubble
    }()
    
    private let bubbleText: CATextLayer = {
        let bubbleText = CATextLayer()
        bubbleText.backgroundColor = UIColor.clear.cgColor
        bubbleText.font = UIFont(name: "Gotham-Bold", size: 11)
        bubbleText.fontSize = 11
        bubbleText.foregroundColor = UIColor.whiteThree.cgColor
        bubbleText.alignmentMode = .center
        bubbleText.contentsScale = UIScreen.main.scale
        return bubbleText
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        icon.frame = CGRect(x: 43.5, y: 0, width: 45, height: 45)
        layer.addSublayer(icon)
        bubble.frame = CGRect(x: 0, y: 39, width: 132, height: 22)
        layer.addSublayer(bubble)
        bubbleText.frame = CGRect(x: 15, y: 44, width: 102, height: 12)
        layer.addSublayer(bubbleText)
        setNeedsLayout()
    }
    
    func setup(for text: String) {
        let font = UIFont(name: "Gotham-Bold", size: 11) ?? UIFont.boldSystemFont(ofSize: 11)
        var size = text.size(font: font)
        size.width = min(size.width, 102)
        
        
        var frame = CGRect(
            x: 66 - size.width / 2,
            y: 39 + (22 - size.height) / 2,
            width: size.width,
            height: size.height)
        
        bubbleText.frame = frame
        bubbleText.string = text
        
        frame.origin.x -= 15
        frame.origin.y = 0
        frame.size.width += 30
        frame.size.height = 22
        bubble.path = UIBezierPath(roundedRect: frame, cornerRadius: 11).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleText.string = ""
        
    }
}
