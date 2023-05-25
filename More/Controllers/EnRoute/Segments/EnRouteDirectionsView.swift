//
//  EnRouteDirectionsView.swift
//  More
//
//  Created by Luko Gjenero on 26/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections

@IBDesignable
class EnRouteDirectionsView: LoadableView {

    @IBOutlet private weak var instruction: UIImageView!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var thinSeparator: UIView!
    @IBOutlet private weak var directionsTop: UILabel!
    @IBOutlet private weak var directionsBottom: UILabel!
    
    
    override func setupNib() {
        super.setupNib()
        enableShadow(color: .black)
    }
    
    func setup(maneuver: ManeuverType, direction: ManeuverDirection, distance: CLLocationDistance, instructions: String) {

        var image = UIImage(named: "go-straight")
        switch maneuver {
        case .turn:
            switch direction {
            case .left, .sharpLeft, .slightLeft:
                image = UIImage(named: "turn-left")
            case .right, .sharpRight, .slightRight:
                image = UIImage(named: "turn-right")
            default: ()
            }
        default: ()
        }
        instruction.image = image
        
        distanceLabel.text = "\(Int(distance.metersToFeet())) ft"
        if let idx = instructions.firstIndex(of: " on ") {
            let line1 = instructions.substring(to: idx + 3)
            let line2 = instructions.substring(from: idx + 4)
            directionsTop.text = line1
            directionsBottom.text = line2
        } else {
            directionsTop.text = ""
            directionsBottom.text = instructions
        }
    }
    
}
