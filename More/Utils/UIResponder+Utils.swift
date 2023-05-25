//
//  UIResponder+Utils.swift
//  More
//
//  Created by Igor Ostriz on 08/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit


extension UIResponder {

    static private weak var firstResponder: UIResponder?
    
    static func resignAnyFirstResponder() {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    static func currentFirstResponder() -> UIResponder? {
        firstResponder = nil;
        UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
        return firstResponder
    }
    
    @objc func findFirstResponder(sender: Any) {
        UIResponder.firstResponder = self
    }

    func currentFirstResponder() {
        UIResponder.firstResponder = nil;
        UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
    }
    
}
