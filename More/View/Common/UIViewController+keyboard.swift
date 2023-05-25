//
//  UIViewController+keyboard.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private var bottomContraintKey: UInt8 = 0
private var trackRespondersKey: UInt8 = 0
private var originalBottomConstraintKey: UInt8 = 0

extension UIViewController {

    /// bottom constraint
    weak var bottomContraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &bottomContraintKey) as? NSLayoutConstraint
        }
        set {
            objc_setAssociatedObject(self, &bottomContraintKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            if let constraint = newValue {
                originalBottomConstraint = constraint.constant
            }
        }
    }
    
    /// Adds keyboard tracking code and pushes the view controller content up
    func trackKeyboardAndPushUp() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowOrHide(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowOrHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    func stopTrackingKeyboard() {
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    /// Is viewController visible
    var isVisible: Bool {
        return viewIfLoaded?.window != nil
    }
    
    func trackKeyboard(onlyFor responders: [UIResponder]) {
        trackResponders = responders
    }
    
    private var trackResponders: [UIResponder]? {
        get {
            return objc_getAssociatedObject(self, &trackRespondersKey) as? [UIResponder]
        }
        set {
            objc_setAssociatedObject(self, &trackRespondersKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var originalBottomConstraint: CGFloat {
        get {
            return objc_getAssociatedObject(self, &originalBottomConstraintKey) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, &originalBottomConstraintKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @objc private func keyboardWillShowOrHide(notification: Notification) {
        
        if let firstResponder =  UIResponder.currentFirstResponder(), trackResponders?.contains(firstResponder) == false { return }
        guard let bottomContraint = bottomContraint else { return }
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            
            let screenHeight = UIScreen.main.bounds.height
            var keyboardHeight = keyboardSize.origin.y == screenHeight ? 0 : keyboardSize.height - self.view.safeAreaInsets.bottom
            
            if keyboardHeight > 0 {
                if !(bottomContraint.firstAnchor == self.view.bottomAnchor || bottomContraint.firstAnchor == self.view.safeAreaLayoutGuide.bottomAnchor) {
                    keyboardHeight = -keyboardHeight
                }
                guard bottomContraint.constant != keyboardHeight else { return }
            } else {
                guard bottomContraint.constant != originalBottomConstraint else { return }
                keyboardHeight = originalBottomConstraint
            }
            
            if isVisible {
                UIView.animate(
                    withDuration: animationDuration.doubleValue,
                    delay: 0.0,
                    options: [.beginFromCurrentState, UIView.AnimationOptions(rawValue: animationCurve.uintValue)],
                    animations: { [weak self] in
                        bottomContraint.constant = keyboardHeight
                        self?.viewIfLoaded?.layoutIfNeeded()
                    },
                    completion: nil)
            }
        } else {
            bottomContraint.constant = 0
        }
    }
}
