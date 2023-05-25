//
//  CreateSignalSetupItem.swift
//  More
//
//  Created by Luko Gjenero on 06/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CreateSignalSetupItem: LoadableView {

    @IBOutlet fileprivate weak var icon: UIButton!
    @IBOutlet fileprivate weak var title: UILabel!
    @IBOutlet fileprivate weak var subtitle: UILabel!
    @IBOutlet fileprivate weak var button: UIButton!
    @IBOutlet fileprivate weak var tick: UIButton!
    @IBOutlet fileprivate weak var caret: UIImageView!

    var isSelected: Bool {
        get {
            return icon.isSelected
        }
        set {
            icon.isSelected = newValue
            tick.isSelected = newValue
        }
    }
    
    var tap: (()->())?
    
    @IBAction private func touched(_ sender: Any) {
        tap?()
    }
    
}

@IBDesignable
class CreateSignalPlaceItem: CreateSignalSetupItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalSetupItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        tick.isHidden = true
        
        icon.setImage(UIImage(named: "create-pin-off"), for: .normal)
        icon.setImage(UIImage(named: "create-pin-on"), for: .selected)
    }
    
    func setup(for model: CreateExperienceViewModel) {
        if model.destination != nil {
            icon.isSelected = true
            title.text = model.destinationName
            subtitle.text = model.destinationAddress
        } else {
            if model.somewhere {
                icon.isSelected = true
                title.text = "Anywhere"
                subtitle.text = "THIS CAN BE DONE WHEREVER"
            } else {
                icon.isSelected = false
                title.text = "Where?"
                subtitle.text = "WHERE THIS TAKES PLACE"
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        icon.isSelected = false
        title.text = "Where?"
        subtitle.text = "WHERE THIS TAKES PLACE"
    }
}

@IBDesignable
class CreateSignalScheduleItem: CreateSignalSetupItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalSetupItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        tick.isHidden = true
        
        icon.setImage(UIImage(named: "create-time-off"), for: .normal)
        icon.setImage(UIImage(named: "create-time-on"), for: .selected)
    }
    
    func setup(for model: CreateExperienceViewModel) {
        if let schedule = model.schedule {
            icon.isSelected = true
            title.text = "Scheduled"
            let df = DateFormatter()
            df.dateFormat = "MM/dd/YYYY"
            if let start = schedule.start {
                if let end = schedule.end {
                    subtitle.text = df.string(from: start) + " - " + df.string(from: end)
                } else {
                    subtitle.text = "Starting on " + df.string(from: start)
                }
            } else if let end = schedule.end {
                subtitle.text = "Ending on " + df.string(from: end)
            } else {
                subtitle.text = "Ongoing"
            }
            
        } else {
            if model.sometime {
                icon.isSelected = true
                title.text = "Anytime"
                subtitle.text = "THIS CAN BE DONE WHENEVER"
            } else {
                icon.isSelected = false
                title.text = "When?"
                subtitle.text = "WHEN THIS CAN BE DONE"
            }
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        icon.isSelected = false
        title.text = "When?"
        subtitle.text = "WHEN THIS CAN BE DONE"
    }
}

@IBDesignable
class CreateSignalPlaceAnywhereItem: CreateSignalSetupItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalSetupItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        caret.isHidden = true
        
        icon.setImage(UIImage(named: "create-location-off"), for: .normal)
        icon.setImage(UIImage(named: "create-location-on"), for: .selected)
        
        title.text = "Anywhere"
        subtitle.text = "YOU CAN DO THIS WHEREVER"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        icon.isSelected = true
        title.text = "Anywhere"
        subtitle.text = "YOU CAN DO THIS WHEREVER"
    }
}

@IBDesignable
class CreateSignalPlaceSomewhereItem: CreateSignalSetupItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalSetupItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        caret.isHidden = true
        
        icon.setImage(UIImage(named: "create-pin-off"), for: .normal)
        icon.setImage(UIImage(named: "create-pin-on"), for: .selected)
        
        title.text = "Specify Location"
        subtitle.text = "I HAVE A PLACE IN MIND"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        icon.isSelected = true
        title.text = "Specify Location"
        subtitle.text = "I HAVE A PLACE IN MIND"
    }
}

@IBDesignable
class CreateSignalScheduleAnytimeItem: CreateSignalSetupItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalSetupItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        caret.isHidden = true
        
        icon.setImage(UIImage(named: "create-anytime-off"), for: .normal)
        icon.setImage(UIImage(named: "create-anytime-on"), for: .selected)
        icon.imageView?.contentMode = .center
        
        title.text = "Anytime"
        subtitle.text = "THIS CAN BE DONE WHENEVER"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        icon.isSelected = true
        title.text = "Anytime"
        subtitle.text = "THIS CAN BE DONE WHENEVER"
    }
}

@IBDesignable
class CreateSignalScheduleSometimeItem: CreateSignalSetupItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalSetupItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        caret.isHidden = true
        
        icon.setImage(UIImage(named: "create-time-off"), for: .normal)
        icon.setImage(UIImage(named: "create-time-on"), for: .selected)
        
        title.text = "Scheduled"
        subtitle.text = "THIS HAS SET HOURS"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        icon.isSelected = true
        title.text = "Scheduled"
        subtitle.text = "THIS HAS SET HOURS"
    }
}

@IBDesignable
class CreateSignalPlaceSearchItem: CreateSignalSetupItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalSetupItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        tick.isHidden = true
        caret.isHidden = true
        button.isHidden = true
        
        icon.setImage(UIImage(named: "create-pin-off"), for: .normal)
        icon.setImage(UIImage(named: "create-pin-on"), for: .selected)
    }
    
    func setup(for place: PlacesSearchService.PlaceData) {
        icon.isSelected = false
            title.text = place.name
            subtitle.text = place.address
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        icon.isSelected = false
        title.text = "Gramercy, Manhattan"
        subtitle.text = "NEW YORK, NY"
    }
}

