//
//  ExperienceDetailsTransitioningDelegate.swift
//  More
//
//  Created by Luko Gjenero on 17/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}

class ExperienceDetailsTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    let interactor = Interactor()
    let transition = ExperienceDetailsTransition()
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}


