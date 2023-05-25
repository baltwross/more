//
//  CreateSignalPlaceSelectorView.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CreateSignalPlaceSelectorView: LoadableView {

    enum SelectionType {
        case none, anywhere, somewhere
    }
    
    @IBOutlet private weak var topBar: CreateSignalPlaceSelectorTopBar!
    @IBOutlet private weak var anywhereView: CreateSignalPlaceAnywhereItem!
    @IBOutlet private weak var somewhereView: CreateSignalPlaceSomewhereItem!
    
    var close: (()->())?
    var done: (()->())?
    var anywhere: (()->())?
    var somewhere: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        anywhereView.isSelected = false
        somewhereView.isSelected = false
        
        topBar.backTap = { [weak self] in
            self?.close?()
        }
        topBar.doneTap = { [weak self] in
            self?.done?()
        }
        anywhereView.tap = { [weak self] in
            self?.anywhereView.isSelected = true
            self?.somewhereView.isSelected = false
            self?.anywhere?()
        }
        somewhereView.tap = { [weak self] in
            self?.anywhereView.isSelected = false
            self?.somewhereView.isSelected = true
            self?.somewhere?()
        }
    }
    
    var selection: SelectionType {
        get {
            if anywhereView.isSelected {
                return .anywhere
            }
            if somewhereView.isSelected {
                return .somewhere
            }
            return .none
        }
        set {
            switch newValue {
            case .anywhere:
                anywhereView.isSelected = true
                somewhereView.isSelected = false
            case .somewhere:
                anywhereView.isSelected = false
                somewhereView.isSelected = true
            default:
                anywhereView.isSelected = false
                somewhereView.isSelected = false
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
