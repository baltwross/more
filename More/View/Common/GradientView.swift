//
//  GradientView.swift
//  More
//
//  Created by Luko Gjenero on 08/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    var colors: [CGColor] = [] {
        didSet {
            setupGradient()
        }
    }
    
    var locations: [NSNumber]? = nil {
        didSet {
            setupGradient()
        }
    }
    
    var start: CGPoint = .zero {
        didSet {
            setupGradient()
        }
    }
    
    var end: CGPoint = .zero {
        didSet {
            setupGradient()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private let gradient = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
    fileprivate func setup() {
        setupGradient()
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupGradient() {
        gradient.startPoint = start
        gradient.endPoint = end
        gradient.locations = locations
        gradient.colors = colors
    }
    
    func animate(to colors: [CGColor]) {
        let gradientAnimation = CAKeyframeAnimation(keyPath: "colors")
        gradientAnimation.values = [self.colors, colors, self.colors]
        gradientAnimation.duration = 3.0
        gradientAnimation.repeatCount = Float.infinity
        gradientAnimation.isRemovedOnCompletion = true
        gradient.add(gradientAnimation, forKey: "colors")        
    }
}

@IBDesignable
class HorizontalGradientView: GradientView {
    
    override func setup() {
        start = CGPoint(x: 0, y: 0.5)
        end = CGPoint(x: 1, y: 0.5)
        
        super.setup()
    }
}

@IBDesignable
class VerticalGradientView: GradientView {
    
    override func setup() {
        start = CGPoint(x: 0.5, y: 0)
        end = CGPoint(x: 0.5, y: 1)
        
        super.setup()
    }
}
