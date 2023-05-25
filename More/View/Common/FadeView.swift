//
//  FadeView.swift
//  More
//
//  Created by Luko Gjenero on 28/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class FadeView: UIView {

    enum Orientation {
        case up, down
    }
    
    private let gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = [0, 1.0] // [0, 0.8, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    var color: UIColor = .clear {
        didSet {
            updateColors()
        }
    }
    
    var orientation: Orientation = .up {
        didSet {
            updateColors()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
    private func setup() {
        layer.insertSublayer(gradient, at: 0)
    }
    
    private func updateColors() {
        if orientation == .up {
            gradient.colors = [
                color.withAlphaComponent(0).cgColor,
                // color.cgColor,
                color.cgColor]
        } else {
            gradient.colors = [
                color.cgColor,
                // color.cgColor,
                color.withAlphaComponent(0).cgColor]
        }
    }

}
