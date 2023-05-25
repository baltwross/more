//
//  AvatarImage.swift
//  More
//
//  Created by Luko Gjenero on 09/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
class AvatarImage: UIImageView {

    private class RingLayer: UIView {
        
        var outerColor: UIColor = Colors.avatarOuterRing {
            didSet {
                setNeedsDisplay()
            }
        }
        var outerWidth: CGFloat = 0.5 {
            didSet {
                setNeedsDisplay()
            }
        }
        var mainColor: UIColor = Colors.avatarInnerRing {
            didSet {
                setNeedsDisplay()
            }
        }
        var mainWidth: CGFloat = 2.5 {
            didSet {
                setNeedsDisplay()
            }
        }
        var innerColor: UIColor = Colors.avatarOuterRing {
            didSet {
                setNeedsDisplay()
            }
        }
        var innerWidth: CGFloat = 0.25 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override func draw(_ rect: CGRect) {
            if let ctx = UIGraphicsGetCurrentContext() {
                draw(ctx: ctx)
            }
        }
        
        override func draw(_ layer: CALayer, in ctx: CGContext) {
            draw(ctx: ctx)
        }
        
        private func draw(ctx: CGContext) {
            
            ctx.setAllowsAntialiasing(true)
            ctx.setShouldAntialias(true)
            ctx.interpolationQuality = .high
            
            ctx.setStrokeColor(outerColor.cgColor)
            ctx.setLineWidth(outerWidth + 1)
            ctx.addPath(outerPath.cgPath)
            ctx.drawPath(using: .stroke)
            
            ctx.setStrokeColor(mainColor.cgColor)
            ctx.setLineWidth(mainWidth)
            ctx.addPath(mainPath.cgPath)
            ctx.drawPath(using: .stroke)
            
            ctx.setStrokeColor(innerColor.cgColor)
            ctx.setLineWidth(innerWidth)
            ctx.addPath(innerPath.cgPath)
            ctx.drawPath(using: .stroke)
        }
        
        var innerPath: UIBezierPath {
            let inset = outerWidth + mainWidth + innerWidth * 0.5
            return UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
        }
        
        var mainPath: UIBezierPath {
            let inset = outerWidth + mainWidth * 0.5
            return UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
        }
        
        var outerPath: UIBezierPath {
            let inset = outerWidth * 0.5 - 0.5
            return UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
        }
        
    }
    
    private let ringLayer: RingLayer = {
        let layer = RingLayer()
        layer.isOpaque = false
        layer.backgroundColor = .clear
        layer.translatesAutoresizingMaskIntoConstraints = false
        return layer
    }()
    
    @IBInspectable public var ringSize: CGFloat = 0 {
        didSet {
            ringLayer.mainWidth = ringSize
        }
    }
    
    @IBInspectable public var ringColor: UIColor {
        get {
            return ringLayer.mainColor
        }
        set {
            ringLayer.mainColor = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setup()
    }
    
    private func setup() {
        contentMode = .scaleAspectFill
        addSubview(ringLayer)
        ringLayer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        ringLayer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        ringLayer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        ringLayer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        ringLayer.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShape()
    }
    
    private func setupShape() {
        layer.masksToBounds = true
        layer.cornerRadius = min(frame.width, frame.height) * 0.5
        bringSubviewToFront(ringLayer)
    }
    
}
