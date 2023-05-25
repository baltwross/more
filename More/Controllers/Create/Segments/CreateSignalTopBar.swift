//
//  CreateSignalTopBar.swift
//  More
//
//  Created by Luko Gjenero on 13/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CreateSignalTopBar: LoadableView {

    @IBOutlet fileprivate weak var backButton: UIButton!
    @IBOutlet fileprivate weak var title: UILabel!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    
    var backTap: (()->())?
    var doneTap: (()->())?
    
    // MARK: - buttons
    
    @IBAction private func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction private func doneTouch(_ sender: Any) {
        doneTap?()
    }
}

@IBDesignable
class CreateSignalPlaceSelectorTopBar: CreateSignalTopBar {
    
    public override var nibName: String {
        return String(describing: CreateSignalTopBar.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        backButton.setImage(UIImage(named: "close_gray"), for: .normal)
        doneButton.isHidden = true
        title.text = "Where?"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backButton.setImage(UIImage(named: "close_gray"), for: .normal)
        doneButton.isHidden = true
        title.text = "Where?"
    }
    
    var doneIsHidden: Bool {
        get {
            return doneButton.isHidden
        }
        set{
            doneButton.isHidden = newValue
        }
    }
}

@IBDesignable
class CreateSignalPlaceSearchPanelTopBar: CreateSignalTopBar {
    
    public override var nibName: String {
        return String(describing: CreateSignalTopBar.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        doneButton.isHidden = true
        title.text = "Location"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        doneButton.isHidden = true
        title.text = "Location"
    }
    
    var doneIsHidden: Bool {
        get {
            return doneButton.isHidden
        }
        set{
            doneButton.isHidden = newValue
        }
    }
}

@IBDesignable
class CreateSignalScheduleSelectorTopBar: CreateSignalTopBar {
    
    public override var nibName: String {
        return String(describing: CreateSignalTopBar.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        doneButton.isHidden = true
        title.text = "When?"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        doneButton.isHidden = true
        title.text = "When?"
    }
    
    var doneIsHidden: Bool {
        get {
            return doneButton.isHidden
        }
        set{
            doneButton.isHidden = newValue
        }
    }
}

@IBDesignable
class CreateSignalScheduleSetupTopBar: CreateSignalTopBar {
    
    public override var nibName: String {
        return String(describing: CreateSignalTopBar.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        doneButton.setTitleColor(.lightPeriwinkle, for: .disabled)
        doneButton.isEnabled = false
        title.text = "Schedule"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        doneButton.setTitleColor(.lightPeriwinkle, for: .disabled)
        doneButton.isEnabled = false
        title.text = "Schedule"
    }
    
    var doneIsEnabled: Bool {
        get {
            return doneButton.isEnabled
        }
        set{
            doneButton.isEnabled = newValue
        }
    }
}

@IBDesignable
class CreateSignalScheduleTimeboxTopBar: CreateSignalTopBar {
    
    public override var nibName: String {
        return String(describing: CreateSignalTopBar.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        doneButton.setTitleColor(.lightPeriwinkle, for: .disabled)
        doneButton.setTitle("SET", for: .normal)
        doneButton.isEnabled = false
        title.text = "Set Hours"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        doneButton.setTitleColor(.lightPeriwinkle, for: .disabled)
        doneButton.setTitle("SET", for: .normal)
        doneButton.isEnabled = false
        title.text = "Set Hours"
    }
    
    var doneIsEnabled: Bool {
        get {
            return doneButton.isEnabled
        }
        set{
            doneButton.isEnabled = newValue
        }
    }
}

@IBDesignable
class CreateSignalScheduleStartStopTopBar: CreateSignalTopBar {
    
    public override var nibName: String {
        return String(describing: CreateSignalTopBar.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        title.text = "Duration"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backButton.setImage(UIImage(named: "create-back"), for: .normal)
        title.text = "Duration"
    }
}

@IBDesignable
class CreateSignalMoodTopBar: CreateSignalTopBar {
    
    public override var nibName: String {
        return String(describing: CreateSignalTopBar.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        backButton.setImage(UIImage(named: "close_gray"), for: .normal)
        title.text = "Choose the Mood"
        doneButton.isHidden = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backButton.setImage(UIImage(named: "close_gray"), for: .normal)
        title.text = "Choose the Mood"
        doneButton.isHidden = true
    }
}

@IBDesignable
class ChatMeetingSearchPanelTopBar: CreateSignalTopBar {
    
    public override var nibName: String {
        return String(describing: CreateSignalTopBar.self)
    }
    
    override func setupNib() {
        super.setupNib()
        
        backButton.setImage(UIImage(named: "close_gray"), for: .normal)
        doneButton.setTitleColor(.lightPeriwinkle, for: .disabled)
        doneButton.setTitle("SET", for: .normal)
        doneButton.isHidden = true
        title.text = "Meeting Place"
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backButton.setImage(UIImage(named: "close_gray"), for: .normal)
        doneButton.setTitleColor(.lightPeriwinkle, for: .disabled)
        doneButton.setTitle("SET", for: .normal)
        doneButton.isHidden = true
        title.text = "Meeting Place"
    }
    
    var doneIsHidden: Bool {
        get {
            return doneButton.isHidden
        }
        set{
            doneButton.isHidden = newValue
        }
    }
}
