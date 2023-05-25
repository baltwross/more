//
//  UIViewController+overlay.swift
//  More
//
//  Created by Luko Gjenero on 25/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

extension UIViewController {

    
    // MARK - enter / exit animations
    
    func setupForEnterFromBelow() {
        view.backgroundColor = .clear
        let transform = CATransform3DMakeTranslation(0, view.frame.height, 0)
        for view in self.view.subviews {
            view.layer.transform = transform
        }
    }
    
    func enterFromBelow() {
        UIView.animate(
        withDuration: 0.3) {
            for view in self.view.subviews {
                view.layer.transform = CATransform3DIdentity
            }
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }
    
    func exitFromBelow(_ complete: (()->())?) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let transform = CATransform3DMakeTranslation(0, view.frame.height, 0)
        UIView.animate(
            withDuration: 0.3,
            animations: {
                for view in self.view.subviews {
                    view.layer.transform = transform
                }
                self.view.backgroundColor = .clear
            },
            completion: { (_) in
                complete?()
            })
    }
    
    func setupForEnterFromAbove() {
        view.backgroundColor = .clear
        let transform = CATransform3DMakeTranslation(0, -view.frame.height, 0)
        for view in self.view.subviews {
            view.layer.transform = transform
        }
    }
    
    func enterFromAbove() {
        UIView.animate(
        withDuration: 0.3) {
            for view in self.view.subviews {
                view.layer.transform = CATransform3DIdentity
            }
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }
    
    func exitFromAbove(_ complete: (()->())?) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let transform = CATransform3DMakeTranslation(0, -view.frame.height, 0)
        UIView.animate(
            withDuration: 0.3,
            animations: {
                for view in self.view.subviews {
                    view.layer.transform = transform
                }
                self.view.backgroundColor = .clear
            },
            completion: { (_) in
                complete?()
            })
    }

}

extension UIView {
    // MARK - enter / exit animations
    
    func setupForEnterFromBelow() {
        backgroundColor = .clear
        let transform = CATransform3DMakeTranslation(0, frame.height, 0)
        for view in self.subviews {
            view.layer.transform = transform
        }
    }
    
    func enterFromBelow() {
        UIView.animate(
        withDuration: 0.3) {
            for view in self.subviews {
                view.layer.transform = CATransform3DIdentity
            }
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }
    
    func exitFromBelow(_ complete: (()->())?) {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let transform = CATransform3DMakeTranslation(0, frame.height, 0)
        UIView.animate(
            withDuration: 0.3,
            animations: {
                for view in self.subviews {
                    view.layer.transform = transform
                }
                self.backgroundColor = .clear
            },
            completion: { (_) in
                complete?()
            })
    }
    
    func setupForEnterFromAbove() {
        backgroundColor = .clear
        let transform = CATransform3DMakeTranslation(0, -frame.height, 0)
        for view in self.subviews {
            view.layer.transform = transform
        }
    }
    
    func enterFromAbove() {
        UIView.animate(
        withDuration: 0.3) {
            for view in self.subviews {
                view.layer.transform = CATransform3DIdentity
            }
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }
    
    func exitFromAbove(_ complete: (()->())?) {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let transform = CATransform3DMakeTranslation(0, -frame.height, 0)
        UIView.animate(
            withDuration: 0.3,
            animations: {
                for view in self.subviews {
                    view.layer.transform = transform
                }
                self.backgroundColor = .clear
            },
            completion: { (_) in
                complete?()
            })
    }
}
