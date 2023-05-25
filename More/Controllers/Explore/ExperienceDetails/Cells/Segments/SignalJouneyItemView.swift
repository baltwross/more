//
//  SignalJouneyItemView.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class SignalJourneyItemView: LoadableView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var eta: CountdownLabel!
    @IBOutlet weak var etaLabel: UILabel!
    
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
    
    private func setupForNearby() {
        icon.image = UIImage(named: "nearby")
        eta.isHidden = false
        etaLabel.isHidden = false
    }
    
    private func setupForFinal() {
        icon.image = UIImage(named: "pin")
        eta.isHidden = true
        etaLabel.isHidden = true
    }
    
    private func setupForSomewhere() {
        icon.image = UIImage(named: "nearby")
        eta.isHidden = true
        etaLabel.isHidden = true
    }
    
    private func setupForAdd() {
        icon.image = UIImage(named: "pin_off")
        eta.isHidden = true
        etaLabel.isHidden = true
    }
    
    private func setupForDestination() {
        icon.image = UIImage(named: "pin_on")
        eta.isHidden = true
        etaLabel.isHidden = true
    }
    
    override func setupNib() {
        super.setupNib()
        eta.setDateFormat("m:ssa")
    }

    func setup(for model: SignalViewModel) {
        if type == ItemType.nearby.rawValue {
            title.text = "Meet Nearby"
            distance.text = "UNDER 10 MINUES BY FOOT"
            eta.countdown(to: model.expiresAt)
        } else {
            title.text = "Patent Pending"
            distance.text = "49 W 27TH ST, NEW YORK"
        }
    }
    
    func setup(for model: CreateSignalViewModel) {
        if type == ItemType.nearby.rawValue {
            title.text = "Meet Nearby"
            distance.text = "UNDER 10 MINUES BY FOOT"
            eta.isHidden = true
            etaLabel.isHidden = true
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
            distance.text = model.destinationAddress
        }
    }
    
    func setup(for item: PlacesSearchService.PlaceData) {
        if type == ItemType.somewhere.rawValue {
            title.text = "Somewhere nearby"
            distance.text = "WE'LL DECIDE TOGEHER"
        } else  if type == ItemType.add.rawValue {
            title.text = item.name
            distance.text = item.address
        } else {
            title.text = item.name
            distance.text = item.address
        }
    }
}
