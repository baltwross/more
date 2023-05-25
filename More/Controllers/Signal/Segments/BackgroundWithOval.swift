//
//  BackgroundWithOval.swift
//  More
//
//  Created by Luko Gjenero on 26/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class BackgroundWithOval: UIView {

    private let semicircle: CAShapeLayer = {
       let semicircle = CAShapeLayer()
        semicircle.fillColor = nil
        semicircle.strokeColor = nil
        semicircle.lineJoin = CAShapeLayerLineJoin.bevel
        semicircle.lineWidth = 1
        return semicircle
    }()
    
    
    @objc enum OvalPosition: Int {
        case bottom, top
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false
        layer.masksToBounds = false
        layer.insertSublayer(semicircle, at: 0)
        layer.insertSublayer(background, at: 0)
        updatePath()
    }
    
    override var backgroundColor: UIColor? {
        get {
            if let cgColor = background.fillColor {
                return  UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            background.fillColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var ovalPosition: Int = OvalPosition.bottom.rawValue {
        didSet {
            updatePath()
        }
    }
    
    @IBInspectable var ovalSize: CGFloat = 75 {
        didSet {
            updatePath()
        }
    }
    
    @IBInspectable var ovalOffset: CGFloat = 0 {
        didSet {
            updatePath()
        }
    }
    
    @IBInspectable var shadow: Bool = false {
        didSet {
            updatePath()
        }
    }
    
    @IBInspectable var semicircleColor: UIColor? = nil {
        didSet {
            updatePath()
        }
    }
    
    private let background: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private func updatePath() {
        guard OvalPosition(rawValue: ovalPosition) != nil else { return }
        let path = generatePath().cgPath
        background.path = path
        enableShadow(color: shadow ? .black : .clear, path: path)
        
        if let semicircleColor = semicircleColor {
            semicircle.isHidden = false
            semicircle.strokeColor = semicircleColor.cgColor
            semicircle.path = generateSemicirclePath().cgPath
        } else {
            semicircle.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    private func generatePath() -> UIBezierPath {
        
        let radius = ovalSize / 2.0
        let angle = radius > 0 ? acos(abs(ovalOffset / radius)) : 0
        let horizontalOffset = radius > 0 ? sin(angle) * radius : 0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0.0))
        
        if ovalPosition == OvalPosition.top.rawValue, radius > 0 {
            path.addLine(to: CGPoint(x: frame.width * 0.5 - horizontalOffset, y: 0.0))
            path.addArc(withCenter: CGPoint(x: bounds.midX, y: ovalOffset), radius: radius, startAngle: CGFloat(-90).toRadians() - angle, endAngle: CGFloat(-90).toRadians() + angle, clockwise: true)
        }
        
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        path.addLine(to: CGPoint(x: frame.width, y: frame.height))
        
        if ovalPosition == OvalPosition.bottom.rawValue, radius > 0 {
            path.addLine(to: CGPoint(x: frame.width * 0.5 + horizontalOffset, y: frame.height - ovalOffset))
            path.addArc(withCenter: CGPoint(x: bounds.midX, y: frame.height), radius: radius, startAngle: CGFloat(90).toRadians() - angle, endAngle: CGFloat(90).toRadians() + angle, clockwise: true)
        }
        
        path.addLine(to: CGPoint(x: 0, y: frame.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        path.close()
        
        return path
    }
    
    private func generateSemicirclePath() -> UIBezierPath {
        
        var radius = ovalSize / 2.0
        let angle = radius > 0 ? acos(abs(ovalOffset / radius)) : 0
        radius = radius - 2
        let horizontalOffset = radius > 0 ? sin(angle) * radius : 0
        
        let path = UIBezierPath()
        
        if ovalPosition == OvalPosition.top.rawValue, radius > 0 {
            path.move(to: CGPoint(x: frame.width * 0.5 - horizontalOffset, y: 0.0))
            path.addArc(withCenter: CGPoint(x: bounds.midX, y: ovalOffset), radius: radius, startAngle: CGFloat(-90).toRadians() - angle, endAngle: CGFloat(-90).toRadians() + angle, clockwise: true)
            // path.addLine(to: CGPoint(x: frame.width - horizontalOffset, y: 0.0))
        }
        
        if ovalPosition == OvalPosition.bottom.rawValue, radius > 0 {
            path.move(to: CGPoint(x: frame.width * 0.5 + horizontalOffset, y: frame.height - ovalOffset))
            path.addArc(withCenter: CGPoint(x: bounds.midX, y: frame.height), radius: radius, startAngle: CGFloat(90).toRadians() - angle, endAngle: CGFloat(90).toRadians() + angle, clockwise: true)
            // path.addLine(to: CGPoint(x: frame.width - horizontalOffset, y: frame.height - ovalOffset))
        }
        
        path.close()
        
        return path
    }

}
