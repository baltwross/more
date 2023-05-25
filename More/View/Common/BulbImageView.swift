//
//  BulbImageView.swift
//  More
//
//  Created by Luko Gjenero on 14/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class BulbImageView: UIImageView {

    private let bulbMask = CAShapeLayer()
    
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
        bulbMask.fillColor = UIColor.white.cgColor
        layer.mask = bulbMask
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bulbMask.path = createMaskPath().cgPath
    }

    private func createMaskPath() -> UIBezierPath {
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY + 1)
        let radius = bounds.midX
        let yOffset = (1 - cos(CGFloat(0.25))) * radius
        let startAngle = asin(CGFloat(0.25))
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width * 0.4, y: yOffset))
        path.addLine(to: CGPoint(x: frame.width * 0.4, y: 0))
        path.addLine(to: CGPoint(x: frame.width * 0.6, y: 0))
        path.addLine(to: CGPoint(x: frame.width * 0.6, y: yOffset))
        path.addArc(withCenter: center, radius: radius, startAngle: CGFloat.pi * 0.5 + startAngle, endAngle: CGFloat.pi * 3.5 - startAngle, clockwise: true)
        path.close()
        
        return path
    }

}
