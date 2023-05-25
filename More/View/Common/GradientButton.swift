//
//  GradientButton.swift
//  More
//
//  Created by Luko Gjenero on 30/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class GradientButton: UIButton {

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
}

@IBDesignable
class PurpleGradientButton: GradientButton {
    
    override func setup() {
        start = CGPoint(x: 1, y: 0)
        end = CGPoint(x: 0, y: 1)
        setupPurpleGradient()
        
        layer.masksToBounds = true
        
        super.setup()
    }
    
    func setupPurpleGradient() {
        colors = [
            UIColor(red: 3, green: 255, blue: 191).cgColor,
            UIColor.brightSkyBlue.cgColor,
            UIColor(red: 48, green: 183, blue: 255).cgColor,
            UIColor.periwinkle.cgColor
        ]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}


@IBDesignable
class PurpleGradientAndRedButton: PurpleGradientButton {
    
    func setupRed() {
        colors = [
            UIColor.fireEngineRed.cgColor,
            UIColor.fireEngineRed.cgColor,
        ]
    }
}

@IBDesignable
class PurpleGradientAndGreyButton: PurpleGradientButton {
    
    override func setupPurpleGradient() {
        super.setupPurpleGradient()
        setTitleColor(.whiteThree, for: .normal)
    }
    
    func setupGrey() {
        colors = [
            UIColor.lightPeriwinkle.cgColor,
            UIColor.lightPeriwinkle.cgColor,
        ]
        setTitleColor(.blueGrey, for: .normal)
    }
}

@IBDesignable
class PurpleGradientAndBlackButton: PurpleGradientButton {
    
    func setupBlack() {
        colors = [
            UIColor.darkGrey.cgColor,
            UIColor.darkGrey.cgColor,
        ]
    }
}

