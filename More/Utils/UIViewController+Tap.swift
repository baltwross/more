//
//  UIViewController+Tap.swift
//  More
//
//  Created by Luko Gjenero on 16/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private var tapClosureKey: UInt8 = 0

private let tapGestureName = "com.startwithmore.viewcontroller.gestures.tap"

extension UIViewController {
    
    typealias TapClosure = (()->())
    
    /// bottom constraint
    var tapClosure: TapClosure? {
        get {
            return objc_getAssociatedObject(self, &tapClosureKey) as? TapClosure
        }
        set {
            objc_setAssociatedObject(self, &tapClosureKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }

    func trackTap(_ action: TapClosure?) {
        
        tapClosure = action
        
        if action == nil {
            if let tap = view.gestureRecognizers?.first(where: { $0.name == tapGestureName }) {
                view.removeGestureRecognizer(tap)
            }
        } else {
            if view.gestureRecognizers?.first(where: { $0.name == tapGestureName }) == nil {
                let tap = UITapGestureRecognizer(target: self, action: #selector(more_viewController_tapped))
                tap.name = tapGestureName
                view.addGestureRecognizer(tap)
            }
        }
    }
    
    @objc private func more_viewController_tapped() {
        tapClosure?()
    }

}
