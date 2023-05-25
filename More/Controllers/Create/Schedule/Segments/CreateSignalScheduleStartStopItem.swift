//
//  CreateSignalScheduleStartStopItem.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalScheduleStartStopItem: LoadableView {
    
    @IBOutlet fileprivate weak var title: UILabel!
    @IBOutlet fileprivate weak var tick: UIButton!
    @IBOutlet fileprivate weak var button: UIButton!
    
    var isSelected: Bool {
        get {
            return tick.isSelected
        }
        set {
            tick.isSelected = newValue
        }
    }
    
    var tap: (()->())?
    
    @IBAction private func touched(_ sender: Any) {
        tap?()
    }
}

@IBDesignable
class CreateSignalScheduleNowItem: CreateSignalScheduleStartStopItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalScheduleStartStopItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        title.text = "Now"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        title.text = "Now"
    }
}


@IBDesignable
class CreateSignalScheduleNeverItem: CreateSignalScheduleStartStopItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalScheduleStartStopItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        title.text = "Never"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        title.text = "Never"
    }
}

@IBDesignable
class CreateSignalScheduleOnADateItem: CreateSignalScheduleStartStopItem {
    
    public override var nibName: String {
        return String(describing: CreateSignalScheduleStartStopItem.self)
    }
    
    override func setupNib() {
        super.setupNib()
        title.text = "On a Date"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        title.text = "On a Date"
    }
}
