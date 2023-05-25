//
//  EditProfileGenderItemView.swift
//  More
//
//  Created by Luko Gjenero on 16/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EditProfileGenderItemView: LoadableView {

    enum ItemType {
        case male
        case female
        case custom
    }
    
    var done: (()->())?
    
    @IBOutlet private weak var genderField: UITextField!
    @IBOutlet private weak var selectedButton: UIButton!
    
    override func setupNib() {
        super.setupNib()
        
        let done = KeyboardManager.createToolbar()
        done.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        genderField.inputAccessoryView = done
    }
    
    func setup(for type: ItemType, custom: String? = nil) {
        switch type {
        case .male:
            genderField.text = "Male"
            genderField.isUserInteractionEnabled = false
        case .female:
            genderField.text = "Female"
            genderField.isUserInteractionEnabled = false
        case .custom:
            genderField.text = custom
            genderField.isUserInteractionEnabled = true
            
        }
    }
    
    @objc func closeKeyboard() {
        genderField.resignFirstResponder()
        done?()
    }
    
    @IBInspectable var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? .white : .clear
            selectedButton.isSelected = isSelected
        }
    }
    
    var text: String? {
        return genderField.text
    }

}
