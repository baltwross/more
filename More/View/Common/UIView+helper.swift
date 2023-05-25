//
//  UIView+helper.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        // masking
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat, background: UIColor, shadow: UIColor) {
        
        // reset
        layer.mask = nil
        layer.masksToBounds = false
        layer.cornerRadius = 0
        
        // background
        let backgroundPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        var backgroundLayer: CAShapeLayer!
        if let old = layer.sublayers?.first(where: { $0.name == "background" }) as? CAShapeLayer {
            backgroundLayer = old
        } else {
            backgroundLayer = CAShapeLayer()
            backgroundLayer.backgroundColor = nil
            backgroundLayer.name = "background"
            layer.insertSublayer(backgroundLayer, at: 0)
        }
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.fillColor = background.cgColor
        backgroundLayer.frame = bounds
        backgroundColor = .clear
        
        // shadow
        enableShadow(color: shadow, path: backgroundPath.cgPath)
    }
    
    func enableShadow(color: UIColor, path: CGPath? = nil) {
        layer.enableShadow(color: color, path: path)
    }
    
    func enableCardShadow(color: UIColor, path: CGPath? = nil) {
        layer.enableCardShadow(color: color, path: path)
    }
    
    func enableStrongShadow(color: UIColor, opacity: Float = 0.5, path: CGPath? = nil) {
        layer.enableStrongShadow(color: color, opacity: opacity, path: path)
    }
}

extension CALayer {
    
    func enableShadow(color: UIColor, path: CGPath? = nil) {
        shadowColor = color.cgColor
        shadowOffset = .zero
        shadowOpacity = 0.1
        shadowRadius = 5
        shadowPath = path
    }
    
    func enableCardShadow(color: UIColor, path: CGPath? = nil) {
        shadowColor = color.cgColor
        shadowOffset = .zero
        shadowOpacity = 0.1
        shadowRadius = 25
        shadowPath = path
    }
    
    func enableStrongShadow(color: UIColor, opacity: Float = 0.5, path: CGPath? = nil) {
        shadowColor = color.cgColor
        shadowOffset = .zero
        shadowOpacity = opacity
        shadowRadius = 5
        shadowPath = path
    }
}
