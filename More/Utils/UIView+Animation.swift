//
//  UIView+Animation.swift
//  More
//
//  Created by Luko Gjenero on 14/01/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit
import Lottie

extension UIView {
    
    var lottieView: LottieAnimationView? {
        return self.subviews.first as? LottieAnimationView
    }
    
    func addAnimation(resource: String, type: String, directory: String) {
        if let path = Bundle.main.path(forResource: resource, ofType: type, inDirectory: directory) {
            let lottieView = LottieAnimationView(filePath: path)
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = .loop
            lottieView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(lottieView)
            lottieView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            lottieView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            lottieView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            lottieView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
    }
    
    func addWalkingAnimation() {
        addAnimation(resource: "walking-icon", type: "json", directory: "Animations/walk-animation")
    }
    
    func addPurpleWalkingAnimation() {
        addAnimation(resource: "walking-icon", type: "json", directory: "Animations/purple-walk-animation")
    }
    
    func addGhostAnimation() {
        addAnimation(resource: "ghost-animation", type: "json", directory: "Animations/ghost-animation")
    }
    
    func addClockAnimation(dark: Bool) {
        if dark {
            addAnimation(resource: "dark-timer", type: "json", directory: "Animations/dark-timer")
        } else {
            addAnimation(resource: "light-timer", type: "json", directory: "Animations/light-timer")
        }
    }
}
