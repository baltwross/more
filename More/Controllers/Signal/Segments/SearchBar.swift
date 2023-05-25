//
//  SearchBar.swift
//  More
//
//  Created by Luko Gjenero on 26/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class SearchBar: LoadableView, UITextFieldDelegate {

    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var textField: UITextField!

    override func setupNib() {
        super.setupNib()
        
        textField.delegate = self
        textField.insetsLayoutMarginsFromSafeArea = false
        // textField.contentInsetAdjustmentBehavior = .never
        // tableView.insetsContentViewsToSafeArea = false
    }
    
    var textUpdated: ((_ text: String?)->())?
    
    var searchTap: ((_ text: String?)->())?
    
    @IBInspectable var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }
    
    func showKeyboard() {
        textField.becomeFirstResponder()
    }
    
    func hideKeyboard() {
        textField.resignFirstResponder()
    }
    
    @IBAction private func cancelTouch(_ sender: Any) {
        textField.text = ""
        textUpdated?(textField.text)
    }
    
    @IBAction private func textChanged(_ sender: Any) {
        textUpdated?(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTap?(textField.text)
        return false
    }
}
