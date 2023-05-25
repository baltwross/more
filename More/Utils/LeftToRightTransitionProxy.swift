//
//  LeftToRightTransitionProxy.swift
//  More
//
//  Created by Luko Gjenero on 26/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

final class LeftToRightTransitionProxy: NSObject {
    
    func setup(with controller: UINavigationController) {
        controller.delegate = self
    }
}

extension LeftToRightTransitionProxy: UINavigationControllerDelegate {
    
    internal func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return AnimationController(direction: .forward)
        } else {
            return AnimationController(direction: .backward)
        }
    }
}

private final class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Direction {
        case forward, backward
    }
    
    let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else {
                return
        }
        
        let container = transitionContext.containerView
        container.addSubview(toView)
        
        let initialX: CGFloat
        switch direction {
        case .forward: initialX = -fromView.bounds.width
        case .backward: initialX = fromView.bounds.width
        }
        toView.frame = CGRect(origin: CGPoint(x: initialX, y: 0), size: toView.bounds.size)
        
        let animation: () -> Void = {
            toView.frame = CGRect(origin: .zero, size: toView.bounds.size)
        }
        let completion: (Bool) -> Void = { _ in
            let success = !transitionContext.transitionWasCancelled
            if !success {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        }
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: animation,
            completion: completion
        )
    }
}
