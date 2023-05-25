//
//  UINavigationController+push.swift
//  More
//
//  Created by Luko Gjenero on 24/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

extension UINavigationController {

    func pushViewController(_ viewController: UIViewController, animated: Bool, subType: CATransitionSubtype) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = subType
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.window?.layer.add(transition, forKey: kCATransition)
        pushViewController(viewController, animated: false)
    }
    
    func popViewController(animated: Bool, subType: CATransitionSubtype) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = subType
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.window?.layer.add(transition, forKey: kCATransition)
        popViewController(animated: false)
    }

}
