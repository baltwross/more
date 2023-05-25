//
//  UITextFieldKeyboardManager.swift
//  More
//
//  Created by Luko Gjenero on 30/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let KEYBOARD_ANIMATION_DURATION: TimeInterval = 0.3
private let MINIMUM_SCROLL_FRACTION: CGFloat = 0.2
private let MAXIMUM_SCROLL_FRACTION: CGFloat = 0.8
private let PORTRAIT_KEYBOARD_HEIGHT: CGFloat = 216

private var kUITextFieldMaxLenghtKey : UInt8 = 0
private var kUITextFieldToolbarLeftButtonTypeKey : UInt8 = 0
private var kUITextFieldToolbarDelegateKey : UInt8 = 0

protocol KeyboardToolbarDelegate: class {
    func doneButtonClicked(_ textField: Any)
}

class KeyboardManager: NSObject {
    
    weak var containerView: UIView?
    private weak var textField: UITextField?
    private weak var textView: UITextView?
    private var animatedDistance: CGFloat = 0.0
    
    static func createToolbar() -> UIButton {
        let toolbar = UIButton(type: .custom)
        toolbar.frame = CGRect(x: 0, y: 0, width: 320, height: 60)
        toolbar.backgroundColor = .white
        toolbar.titleLabel?.font = UIFont(name: "Gotham-Bold", size: 12) ?? UIFont.systemFont(ofSize: 12)
        toolbar.setTitleColor(Colors.previewLightText, for: .normal)
        toolbar.setTitle("DONE", for: .normal)
        toolbar.enableShadow(color: UIColor.black)
        return toolbar
    }
    
    func manageTextField(_ textField: UITextField, withMaxLength maxLength: Int, showDone: Bool) {
        textField.maxLength = maxLength
        textField.delegate = self
        
        if showDone {
            let button = KeyboardManager.createToolbar()
            button.addTarget(self, action: #selector(doneTouch), for: .touchUpInside)
            textField.inputAccessoryView = button
        }
    }
    
    func manageTextView(_ textView: UITextView, withMaxLength maxLength: Int, showDone: Bool) {
        textView.maxLength = maxLength
        textView.delegate = self
        
        if showDone {
            let button = KeyboardManager.createToolbar()
            button.addTarget(self, action: #selector(doneTouch), for: .touchUpInside)
            textView.inputAccessoryView = button
        }
    }
    
    func setMaxLength(_ lenght: Int, for textField: UITextField) {
        textField.maxLength = lenght
    }
    
    func setToolbarDelegate(_ delegate: KeyboardToolbarDelegate?, for textField: UITextField) {
        textField.toolbarDelegate = delegate
    }
    
    func setMaxLength(_ lenght: Int, for textView: UITextView) {
        textView.maxLength = lenght
    }
    
    func setToolbarDelegate(_ delegate: KeyboardToolbarDelegate?, for textView: UITextView) {
        textView.toolbarDelegate = delegate
    }
    
    @objc private func doneTouch() {
        if let textField = textField {
            textField.toolbarDelegate?.doneButtonClicked(textField)
            textField.resignFirstResponder()
        }
        else if let textView = textView {
            textView.toolbarDelegate?.doneButtonClicked(textView)
            textView.resignFirstResponder()
        }
    }
    
    private func editingBegan(for view: UIView) {
        guard let containerView = containerView else { return }
        
        let textFieldRect: CGRect = containerView.window?.convert(view.bounds, from: view) ?? .zero
        let viewRect: CGRect = containerView.window?.convert(containerView.bounds, from: containerView) ?? .zero
        let midline: CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator: CGFloat = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator: CGFloat = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction: CGFloat = denominator > 0 ? numerator / denominator : 0
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        
        animatedDistance = floor((PORTRAIT_KEYBOARD_HEIGHT + 35) * heightFraction)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(KEYBOARD_ANIMATION_DURATION)
        containerView.layer.transform = CATransform3DMakeTranslation(0, -animatedDistance, 0)
        UIView.commitAnimations()
    }
    
    private func editingEnded(for view: UIView) {
        guard let containerView = containerView else { return }
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(KEYBOARD_ANIMATION_DURATION)
        containerView.layer.transform = CATransform3DIdentity
        UIView.commitAnimations()
        animatedDistance = 0
    }
}

// MARK: - UITextField

extension KeyboardManager: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textField = textField
        editingBegan(for: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.maxLength > 0 {
            let oldCount : Int = textField.text?.count ?? 0
            if let newValue: String = (textField.text as NSString?)?.replacingCharacters(in: range, with: string),
                newValue.count > oldCount && newValue.count > textField.maxLength {
                return false
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editingEnded(for: textField)
        self.textField = nil
    }
}

private extension UITextField {
    
    var maxLength: Int {
        get {
            return objc_getAssociatedObject(self, &kUITextFieldMaxLenghtKey) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &kUITextFieldMaxLenghtKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    weak var toolbarDelegate: KeyboardToolbarDelegate? {
        get {
            return objc_getAssociatedObject(self, &kUITextFieldToolbarDelegateKey) as? KeyboardToolbarDelegate
        }
        set {
            objc_setAssociatedObject(self, &kUITextFieldToolbarDelegateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}


// MARK: - UITextView

extension KeyboardManager: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textView = textView
        editingBegan(for: textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.maxLength > 0 {
            let oldCount : Int = textView.text?.count ?? 0
            if let newValue: String = (textView.text as NSString?)?.replacingCharacters(in: range, with: text),
                newValue.count > oldCount && newValue.count > textView.maxLength {
                return false
            }
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        editingEnded(for: textView)
        self.textView = nil
    }
}

private extension UITextView {
    
    var maxLength: Int {
        get {
            return objc_getAssociatedObject(self, &kUITextFieldMaxLenghtKey) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &kUITextFieldMaxLenghtKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    weak var toolbarDelegate: KeyboardToolbarDelegate? {
        get {
            return objc_getAssociatedObject(self, &kUITextFieldToolbarDelegateKey) as? KeyboardToolbarDelegate
        }
        set {
            objc_setAssociatedObject(self, &kUITextFieldToolbarDelegateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
