//
//  GradientSwitch.swift
//  More
//
//  Created by Luko Gjenero on 20/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class GradientSwitch: UISwitch {
    
    var colors: [UIColor]? = nil {
        didSet {
            setupGradient()
        }
    }
    
    var locations: [CGFloat]? = nil {
        didSet {
            setupGradient()
        }
    }
    
    var start: CGPoint? = nil {
        didSet {
            setupGradient()
        }
    }
    
    var end: CGPoint? = nil {
        didSet {
            setupGradient()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    private func setupGradient() {
        self.onTintColor = .brightSkyBlue // gradientColor(in: self.bounds)
        setNeedsDisplay()
        
        // self.backgroundColor = isOn ? gradientColor(in: self.bounds) : nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradient()
    }
    
    /*
    override var isOn: Bool {
        didSet {
            setupGradient()
        }
    }
    */
    
    private func gradientColor(in rect: CGRect) -> UIColor? {
        guard let image = gradientImage(in: rect) else { return nil }
        return UIColor(patternImage: image)
    }
    
    private func  gradientImage(in rect: CGRect) -> UIImage? {
        
        guard let colors = self.colors else { return nil }
        
        let size = rect.size
        let cgColors = colors.map { $0.cgColor }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        guard let gradient = CGGradient(colorsSpace: colorSpace,
                                        colors: cgColors as CFArray,
                                        locations: locations) else { return nil }
        
        var start: CGPoint = .zero
        if let gradientStart = self.start {
            start = CGPoint(x: size.width * gradientStart.x, y: size.height * gradientStart.y)
        }
        var end: CGPoint = CGPoint(x: size.width, y: 0)
        if let gradientEnd = self.end {
            end = CGPoint(x: size.width * gradientEnd.x, y: size.height * gradientEnd.y)
        }
        
        context!.drawLinearGradient(gradient,
                                    start: start,
                                    end: end,
                                    options: [])
        
        let cgImage = context!.makeImage()
        let image = UIImage.init(cgImage: cgImage!)
        return image
    }
    
}
