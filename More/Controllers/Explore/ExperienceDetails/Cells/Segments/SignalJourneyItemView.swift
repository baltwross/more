//
//  SignalJouneyItemView.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Firebase

@IBDesignable
class SignalJourneyItemView: LoadableView {

    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var distance: UILabel!
    @IBOutlet private weak var eta: UILabel!
    @IBOutlet private weak var etaLabel: UILabel!
    @IBOutlet private weak var topConnection: UIImageView!
    @IBOutlet private weak var bottomConnection: UIImageView!
    @IBOutlet private weak var iconHoleFiller: UIView!
    
    @objc enum ItemType: Int {
        case nearby, final, somewhere, add, destination
    }
    
    @IBInspectable var type: Int = ItemType.nearby.rawValue {
        didSet {
            guard let type = ItemType(rawValue: type) else { return }
            switch type {
            case .nearby:
                setupForNearby()
            case .final:
                setupForFinal()
            case .somewhere:
                setupForSomewhere()
            case .add:
                setupForAdd()
            case .destination:
                setupForDestination()
            }
        }
    }
    
    override func setupNib() {
        super.setupNib()
        self.subviews.first?.clipsToBounds = true
        iconHoleFiller.backgroundColor = backgroundColor
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            iconHoleFiller?.backgroundColor = backgroundColor
        }
    }
    
    private func setupForNearby() {
        icon.image = UIImage(named: "nearby")
        iconHoleFiller.isHidden = true
        eta.isHidden = false
        etaLabel.isHidden = false
    }
    
    private func setupForFinal() {
        icon.image = UIImage(named: "pin")
        iconHoleFiller.isHidden = false
        eta.isHidden = true
        etaLabel.isHidden = true
        etaLabel.text = ""
    }
    
    private func setupForSomewhere() {
        icon.image = UIImage(named: "nearby")
        iconHoleFiller.isHidden = true
        eta.isHidden = true
        etaLabel.isHidden = true
        etaLabel.text = ""
    }
    
    private func setupForAdd() {
        icon.image = UIImage(named: "pin_off")
        iconHoleFiller.isHidden = false
        eta.isHidden = true
        etaLabel.isHidden = true
        etaLabel.text = ""
    }
    
    private func setupForDestination() {
        icon.image = UIImage(named: "pin_on")
        iconHoleFiller.isHidden = false
        eta.isHidden = true
        etaLabel.isHidden = true
        etaLabel.text = ""
    }
    
    private func hideEta() {
        eta.text = ""
        etaLabel.text = ""
        eta.isHidden = false
        etaLabel.isHidden = false
    }
    
    private func setEta(for experience: Experience) {
        setEta(for: experience.destination)
    }
    
    private func setEta(for location: GeoPoint?) {
        hideEta()
        if let myLocation = LocationService.shared.currentLocation,
            let signalLocation = location {
            GeoService.shared.getDistanceAndETA(from: myLocation.coordinate, to: signalLocation.coordinates()) { [weak self] (_, time, _) in
                if let time = time {
                    let df = DateFormatter()
                    df.dateFormat = "h:mm a"
                    self?.eta.text = df.string(from: Date(timeIntervalSinceNow: time))
                    self?.etaLabel.text = "ETA"
                    self?.eta.isHidden = false
                    self?.etaLabel.isHidden = false
                }
            }
        }
    }
    
    private func setNearbyEta(for location: GeoPoint?, address: String) {
        icon.image = UIImage(named: "pin_on")
        iconHoleFiller.isHidden = false
        title.text = ""
        distance.text = ""
        hideEta()
        if let myLocation = LocationService.shared.currentLocation,
            let signalLocation = location {
            GeoService.shared.getDistanceAndETA(from: myLocation.coordinate, to: signalLocation.coordinates()) { [weak self] (_, time, _) in
                if let time = time {
                    let df = DateFormatter()
                    df.dateFormat = "h:mm a"
                    self?.eta.text = df.string(from: Date(timeIntervalSinceNow: time))
                    self?.etaLabel.text = "ETA"
                    self?.eta.isHidden = false
                    self?.etaLabel.isHidden = false
                    self?.title.text = "Meet at \(address)"
                    self?.distance.text = "ABOUT \(Int(time / 60)) MINUTES BY FOOT"
                }
            }
        }
    }
    
    private func setMeetEta(for location: GeoPoint?, address: String) {
        title.text = ""
        distance.text = ""
        hideEta()
        if let myLocation = LocationService.shared.currentLocation,
            let signalLocation = location {
            GeoService.shared.getDistanceAndETA(from: myLocation.coordinate, to: signalLocation.coordinates()) { [weak self] (_, time, _) in
                if let time = time {
                    let df = DateFormatter()
                    df.dateFormat = "h:mm a"
                    self?.eta.text = df.string(from: Date(timeIntervalSinceNow: time))
                    self?.etaLabel.text = "ETA"
                    self?.eta.isHidden = false
                    self?.etaLabel.isHidden = false
                    self?.title.text = "Meet at \(address)"
                    self?.distance.text = "ABOUT \(Int(time / 60)) MINUTES BY FOOT"
                }
            }
        }
    }
    
    func setup(for experience: Experience) {
        if type == ItemType.nearby.rawValue {
            if experience.anywhere == true {
                // anywhere
                if let post = experience.activePost(), let meeting = post.meeting {
                    setNearbyEta(for: meeting, address: post.meetingAddress ?? "Meet point")
                } else {
                    hideEta()
                    title.text = "Meet Nearby"
                    distance.text = "MEETING POINT DETERMINED AFTER YOU CONNECT"
                }
            } else if experience.neighbourhood == nil &&
                experience.city == nil &&
                experience.state == nil {
                // destination
                if let post = experience.activePost(), let meeting = post.meeting {
                    if let destination = experience.destination, destination.equalTo(meeting) {
                        setNearbyEta(for: meeting, address: post.meetingAddress ?? "Meet point")
                    } else {
                        setMeetEta(for: meeting, address: post.meetingAddress ?? "Meet point")
                    }
                } else {
                    hideEta()
                    title.text = "Meet Nearby"
                    distance.text = "MEETING POINT DETERMINED AFTER YOU CONNECT"
                }
            } else {
                // neighbourhood, city or state
                if let post = experience.activePost(), let meeting = post.meeting {
                    setNearbyEta(for: meeting, address: post.meetingAddress ?? "Meet point")
                } else {
                    let place = (experience.neighbourhood ?? experience.city ?? experience.state)?.capitalized ?? "the neighbourhood"
                    title.text = "Meet in \(place)"
                    distance.text = "MEETING POINT DETERMINED AFTER YOU CONNECT"
                }
            }
        } else {
            title.text = "Go to " + (experience.destinationName ?? "final destination")
            distance.text = experience.destinationAddress ?? ""
        }
    }
    
    func setup(for model: CreateExperienceViewModel) {
        if type == ItemType.nearby.rawValue {
            let place = model.destinationNeighbourhood ?? model.destinationCity ?? model.destinationState
            if let place = place {
                title.text = "Meet in \(place)"
                distance.text = "MEETING POINT DETERMINED AFTER YOU CONNECT"
            } else {
                title.text = "Meet Nearby"
                distance.text = "UNDER 10 MINUTES BY FOOT"
            }
            eta.isHidden = true
            etaLabel.isHidden = true
            etaLabel.text = ""
        } else if type == ItemType.somewhere.rawValue {
            title.text = "Somewhere nearby"
            distance.text = "WE'LL DECIDE TOGEHER"
            if model.somewhere {
                icon.image = UIImage(named: "nearby_on")
            }
        } else  if type == ItemType.add.rawValue {
            title.text = "Add destination"
            distance.text = "I HAVE A PLACE IN MIND"
        } else {
            title.text = model.destinationName
            distance.text = model.destinationAddress?.uppercased()
        }
    }
    
    func setup(for item: PlacesSearchService.PlaceData) {
        if type == ItemType.somewhere.rawValue {
            title.text = "Somewhere nearby"
            distance.text = "WE'LL DECIDE TOGEHER"
        } else  if type == ItemType.add.rawValue {
            title.text = item.name
            distance.text = item.address.uppercased()
        } else {
            title.text = item.name
            distance.text = item.address.uppercased()
        }
    }
    
    var topConnectionHidden: Bool {
        get {
            return topConnection.isHidden
        }
        set {
            topConnection.isHidden = newValue
        }
    }
    
    var bottomConnectionHidden: Bool {
        get {
            return bottomConnection.isHidden
        }
        set {
            bottomConnection.isHidden = newValue
        }
    }
}
