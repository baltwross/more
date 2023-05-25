//
//  BorderedImageView.swift
//  More
//
//  Created by Luko Gjenero on 07/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class BorderedImageView: UIImageView {

    private class BorderLayer: UIView {
        
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
        var innerColor: UIColor = Colors.avatarInnerRing {
            didSet {
                setNeedsDisplay()
            }
        }
        var innerWidth: CGFloat = 2.5 {
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
            
            ctx.setShouldAntialias(true)
            ctx.interpolationQuality = .high
            
            ctx.setStrokeColor(outerColor.cgColor)
            ctx.setLineWidth(outerWidth)
            ctx.addPath(outerPath.cgPath)
            ctx.drawPath(using: .stroke)
            
            ctx.setStrokeColor(innerColor.cgColor)
            ctx.setLineWidth(innerWidth)
            ctx.addPath(innerPath.cgPath)
            ctx.drawPath(using: .stroke)
        }
        
        var innerPath: UIBezierPath {
            let inset = outerWidth + innerWidth * 0.5
            return UIBezierPath(rect: bounds.insetBy(dx: inset, dy: inset))
        }
        
        var outerPath: UIBezierPath {
            let inset = outerWidth * 0.5
            return UIBezierPath(rect: bounds.insetBy(dx: inset, dy: inset))
        }
        
    }
    
    private let ringLayer: BorderLayer = {
        let layer = BorderLayer()
        layer.isOpaque = false
        layer.backgroundColor = .clear
        layer.translatesAutoresizingMaskIntoConstraints = false
        return layer
    }()
    
    @IBInspectable public var ringSize: CGFloat = 0 {
        didSet {
            ringLayer.innerWidth = ringSize
        }
    }
    
    @IBInspectable public var ringColor: UIColor {
        get {
            return ringLayer.innerColor
        }
        set {
            ringLayer.innerColor = newValue
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
        bringSubviewToFront(ringLayer)
    }

}
