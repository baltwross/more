//
//  UINavigaViewController+SwipeToPop.swift
//  More
//
//  Created by Luko Gjenero on 04/01/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {

    func enableSwipeToPop() {
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func disableSwipeToPop() {
        interactivePopGestureRecognizer?.delegate = nil
        interactivePopGestureRecognizer?.isEnabled = false
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }

}
