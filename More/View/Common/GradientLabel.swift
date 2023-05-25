//
//  GradientLabel.swift
//  More
//
//  Created by Luko Gjenero on 06/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class GradientLabel: SpecialLabel {

    var gradientColors: [CGColor]? = nil
    var gradientLocations: [CGFloat]? = nil
    var gradientStartPoint: CGPoint? = nil
    var gradientEndPoint: CGPoint? = nil
    
    override func drawText(in rect: CGRect) {
        let oldTextColor = textColor
        if let gradientColor = drawGradientColor(in: rect) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
        self.textColor = oldTextColor
    }
    
    private func drawGradientColor(in rect: CGRect) -> UIColor? {
        
        guard let colors = gradientColors else { return nil }
        
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }
        
        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: gradientLocations) else { return nil }
        
        var start: CGPoint = .zero
        if let gradientStart = gradientStartPoint {
            start = CGPoint(x: size.width * gradientStart.x, y: size.height * gradientStart.y)
        }
        var end: CGPoint = CGPoint(x: size.width, y: 0)
        if let gradientEnd = gradientEndPoint {
            end = CGPoint(x: size.width * gradientEnd.x, y: size.height * gradientEnd.y)
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: start,
                                    end: end,
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
}

class HorizontalGradientLabel: GradientLabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup () {
        gradientLocations = [0, 1]
        gradientStartPoint = CGPoint(x: 0, y: 0.5)
        gradientEndPoint = CGPoint(x: 1, y: 0.5)
    }
}

class VerticalGradientLabel: GradientLabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup () {
        gradientLocations = [0, 1]
        gradientStartPoint = CGPoint(x: 0.5, y: 0)
        gradientEndPoint = CGPoint(x: 0.5, y: 1)
    }
}


