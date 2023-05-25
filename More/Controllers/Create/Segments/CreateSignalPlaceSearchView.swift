//
//  CreateSignalPlaceSearchView.swift
//  More
//
//  Created by Luko Gjenero on 07/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CreateSignalPlaceSearchView: LoadableView, UITextFieldDelegate {

    @IBOutlet private weak var search: UITextField!
    
    var searchChanged: ((_ search: String?)->())?
    var searchFocus: ((_ inFocus: Bool)->())?
    
    var placeholder: String? {
        get {
            return search.placeholder
        }
        set {
            search.placeholder = newValue
        }
    }
    
    var triggerChangeOnReturnOnly: Bool = false
    
    override func setupNib() {
        super.setupNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.masksToBounds = true
        
        search.returnKeyType = .search
        search.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: UITextField.textDidChangeNotification,
            object: search)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textInFocus),
            name: UITextField.textDidBeginEditingNotification,
            object: search)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textOutOfFocus),
            name: UITextField.textDidEndEditingNotification,
            object: search)
        
        let tap = UITapGestureRecognizer(target: search, action: #selector(becomeFirstResponder))
        addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction private func cancelTouch(_ sender: Any) {
        reset()
    }
    
    @objc private func textChanged() {
        if !triggerChangeOnReturnOnly {
            searchChanged?(search.text)
        }
    }
    
    @objc private func textInFocus() {
        searchFocus?(true)
    }
    
    @objc private func textOutOfFocus() {
        searchFocus?(false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if triggerChangeOnReturnOnly {
            searchChanged?(search.text)
        }
        return false
    }
    
    func reset() {
        search.text = nil
        searchChanged?(nil)
    }
    
    func closeKeyboard() {
        search.resignFirstResponder()
    }
}
