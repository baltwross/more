//
//  RoundedMoodLabel.swift
//  More
//
//  Created by Luko Gjenero on 27/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class RoundedMoodBubble: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    var color: UIColor? {
        didSet {
            backgroundColor = color
            lastWidth = 0
            layoutSubviews()
        }
    }
    
    private func setup() {
        layer.cornerRadius = 11
    }
    
    private var lastWidth: CGFloat = 0
    override func layoutSubviews() {
        super.layoutSubviews()
        if lastWidth != bounds.width {
            lastWidth = bounds.width
            enableShadow(color: .black, path: UIBezierPath(roundedRect: bounds, cornerRadius: 11).cgPath)
        }
    }
    
}
