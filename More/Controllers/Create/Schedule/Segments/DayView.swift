//
//  DayView.swift
//  More
//
//  Created by Luko Gjenero on 07/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class DayView: UILabel {
    
    enum Status {
        case none, selected, highlighted
    }
    
    // gradient
    var gradientColors: [CGColor]? = nil
    var gradientLocations: [CGFloat]? = nil
    var gradientStartPoint: CGPoint? = nil
    var gradientEndPoint: CGPoint? = nil
    var gradientWidth: CGFloat = 3
    
    // highlighted
    var highlightTextColor: UIColor? = nil
    
    // selected
    var selectedBackgroundColor: UIColor? = nil
    var selectedTextColor: UIColor? = nil
    
    // border
    var borderColor: UIColor? = nil
    var borderWidth: CGFloat = 1
    
    var status: Status = .none {
        didSet {
            setNeedsDisplay()
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
    
    override func prepareForInterfaceBuilder() {
        status = .highlighted
        text = "M"
    }
    
    private func setup () {
        textAlignment = .center
        font = UIFont(name: "Gotham-Bold", size: 16)
        backgroundColor = UIColor(red: 255, green: 255, blue: 255)
        textColor = .blueGrey
        
        gradientColors = [UIColor.brightSkyBlue.cgColor, UIColor(red: 76, green: 171, blue: 255).cgColor]
        gradientLocations = [0, 1]
        gradientStartPoint = CGPoint(x: 0, y: 0.5)
        gradientEndPoint = CGPoint(x: 1, y: 0.5)
        gradientWidth = 3
        
        highlightTextColor = .charcoalGrey
        
        selectedBackgroundColor = .cornflower
        selectedTextColor = .whiteTwo
        
        borderColor = .lightPeriwinkle
        borderWidth = 1
    }
    
    override func drawText(in rect: CGRect) {
        
        drawBackground(in: rect)
        
        let oldColor = textColor
        if status == .selected {
            textColor = selectedTextColor
        }
        if status == .highlighted {
            textColor = highlightTextColor
        }
        super.drawText(in: rect)
        textColor = oldColor
    }
    
    private func drawBackground(in rect: CGRect) {
        if status == .highlighted {
            drawGradientBackground(in: rect)
            drawBackground(
                in: rect.inset(by: UIEdgeInsets(top: gradientWidth, left: gradientWidth, bottom: gradientWidth, right: gradientWidth)),
                color: backgroundColor)
        } else if status == .selected {
            
            drawBackground(in: rect, color: selectedBackgroundColor)
        } else {
            let inset = borderWidth / 2.0
            let bounds = rect.inset(by: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
            drawBackground(in: bounds, color: backgroundColor)
            drawBorder(in: bounds)
        }
    }
    
    private func drawGradientBackground(in rect: CGRect) {
        
        guard let colors = gradientColors else { return }
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        defer { context?.restoreGState() }
        
        let size = rect.size
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: gradientLocations) else { return }
        
        var start: CGPoint = .zero
        if let gradientStart = gradientStartPoint {
            start = CGPoint(x: size.width * gradientStart.x, y: size.height * gradientStart.y)
        }
        var end: CGPoint = CGPoint(x: size.width, y: 0)
        if let gradientEnd = gradientEndPoint {
            end = CGPoint(x: size.width * gradientEnd.x, y: size.height * gradientEnd.y)
        }
        
        context?.addPath(UIBezierPath(ovalIn: rect).cgPath)
        context?.clip()
        
        context?.drawLinearGradient(gradient,
                                    start: start,
                                    end: end,
                                    options: [])
    }
    
    private func drawBackground(in rect: CGRect, color: UIColor?) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        defer { context?.restoreGState() }
        
        if let bgColor = color {
            context?.setFillColor(bgColor.cgColor)
        }
        context?.addPath(UIBezierPath(ovalIn: rect).cgPath)
        context?.fillPath()
    }
    
    private func drawBorder(in rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        defer { context?.restoreGState() }
        
        if let borderColor = borderColor {
            context?.setStrokeColor(borderColor.cgColor)
        }
        context?.setLineWidth(borderWidth)
        context?.addPath(UIBezierPath(ovalIn: rect).cgPath)
        context?.strokePath()
    }

    
}
