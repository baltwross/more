//
//  MessageBubble.swift
//  More
//
//  Created by Luko Gjenero on 24/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let corner: CGFloat = 8
private let tipSize: CGFloat = 8

class MessageBubble: UIView {

    @objc enum ItemType: Int {
        case incoming, outgoing
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let type = ItemType(rawValue: type) else { return }
        setupForType(type)
        
        layer.insertSublayer(background, at: 0)
    }
    
    @IBInspectable var type: Int = ItemType.incoming.rawValue {
        didSet {
            guard let type = ItemType(rawValue: type) else { return }
            setupForType(type)
            background.path = generatePath().cgPath
        }
    }
    
    private func setupForType(_ type: ItemType) {
        switch type {
        case .incoming:
            background.fillColor = Colors.incomingBubble.cgColor
        case .outgoing:
            background.fillColor = Colors.outgoingBubble.cgColor
        }
    }
    
    private let background: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        background.path = generatePath().cgPath
    }
    
    private func generatePath() -> UIBezierPath {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: corner + tipSize, y: 0.0))
        path.addLine(to: CGPoint(x: frame.size.width - corner, y: 0.0))
        
        path.addArc(withCenter: CGPoint(x: frame.size.width - corner, y: corner), radius: corner, startAngle: CGFloat(-90).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: true)
        
        if type == ItemType.outgoing.rawValue {
            path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height - tipSize * 2 - corner))
            path.addLine(to: CGPoint(x: frame.size.width + tipSize, y: frame.size.height - tipSize - corner))
        }
        
        path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height - corner))
        
        path.addArc(withCenter: CGPoint(x: frame.size.width - corner, y: frame.size.height - corner), radius: corner, startAngle: CGFloat(0).toRadians(), endAngle: CGFloat(90).toRadians(), clockwise: true)
        
        path.addLine(to: CGPoint(x: corner, y: frame.size.height))
        path.addArc(withCenter: CGPoint(x: corner, y: frame.size.height - corner), radius: corner, startAngle: CGFloat(90).toRadians(), endAngle: CGFloat(180).toRadians(), clockwise: true)
        
        if type == ItemType.incoming.rawValue {
            path.addLine(to: CGPoint(x: -tipSize, y: frame.size.height - tipSize - corner))
            path.addLine(to: CGPoint(x: 0, y: frame.size.height - tipSize * 2 - corner))
        }
        
        path.addLine(to: CGPoint(x: 0, y: corner))
        path.addArc(withCenter: CGPoint(x: corner, y: corner), radius: corner, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(270).toRadians(), clockwise: true)
        path.close()
        
        return path
    }

}
