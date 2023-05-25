//
//  ScrollViewHeader.swift
//  More
//
//  Created by Luko Gjenero on 30/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import VisualEffectView

@IBDesignable
class ScrollViewHeader: UIView {

    private let blurView: VisualEffectView = {
        let visualEffectView = VisualEffectView()
        visualEffectView.colorTint = .clear
        visualEffectView.colorTintAlpha = 0.6
        visualEffectView.blurRadius = 10
        visualEffectView.scale = 1
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @IBInspectable var color: UIColor? {
        get {
            return blurView.colorTint
        }
        set {
            blurView.colorTint = newValue
        }
    }
   
    private func setup() {
        insertSubview(blurView, at: 0)
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

}
