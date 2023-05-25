//
//  CreateSignalScheduleSelectorView.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalScheduleSelectorView: LoadableView {

    enum SelectionType {
        case none, anytime, sometime
    }
    
    @IBOutlet private weak var topBar: CreateSignalScheduleSelectorTopBar!
    @IBOutlet private weak var anytimeView: CreateSignalScheduleAnytimeItem!
    @IBOutlet private weak var sometimeView: CreateSignalScheduleSometimeItem!
    
    var close: (()->())?
    var done: (()->())?
    var anytime: (()->())?
    var sometime: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        anytimeView.isSelected = false
        sometimeView.isSelected = false
        
        topBar.backTap = { [weak self] in
            self?.close?()
        }
        topBar.doneTap = { [weak self] in
            self?.done?()
        }
        anytimeView.tap = { [weak self] in
            self?.anytimeView.isSelected = true
            self?.sometimeView.isSelected = false
            self?.anytime?()
        }
        sometimeView.tap = { [weak self] in
            self?.anytimeView.isSelected = false
            self?.sometimeView.isSelected = true
            self?.sometime?()
        }
    }
    
    var selection: SelectionType {
        get {
            if anytimeView.isSelected {
                return .anytime
            }
            if sometimeView.isSelected {
                return .sometime
            }
            return .none
        }
        set {
            switch newValue {
            case .anytime:
                anytimeView.isSelected = true
                sometimeView.isSelected = false
            case .sometime:
                anytimeView.isSelected = false
                sometimeView.isSelected = true
            default:
                anytimeView.isSelected = false
                sometimeView.isSelected = false
            }
        }
    }
    
    var doneIsHidden: Bool {
        get {
            return topBar.doneIsHidden
        }
        set{
            topBar.doneIsHidden = newValue
        }
    }

}
