//
//  RoundedMoodBubble.swift
//  More
//
//  Created by Luko Gjenero on 27/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class RoundedMoodBubble: UIView {
    
    var color: UIColor? {
        didSet {
            lastWidth = 0
            setNeedsLayout()
        }
    }
    
    private var lastWidth: CGFloat = 0
    override func layoutSubviews() {
        super.layoutSubviews()
        if lastWidth != bounds.width {
            lastWidth = bounds.width
            roundCorners(corners: .allCorners, radius: 11, background: color ?? .clear, shadow: .black)
        }
    }
    
}
