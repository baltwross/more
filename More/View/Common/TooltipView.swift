//
//  TooltipView.swift
//  More
//
//  Created by Luko Gjenero on 20/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class TooltipView: UIView {
    private static let color = UIColor(red: 0, green: 0, blue: 0).withAlphaComponent(0.9)

    private static let cornerRadius: CGFloat = 8
    private static let tipSize: CGFloat = 8
    private static let padding: CGFloat = 8
    private static let labelPadding: CGFloat = 16

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .white
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    // MARK: - init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        layer.masksToBounds = false
        layer.addSublayer(bubble)
        layer.addSublayer(tip)

        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: TooltipView.labelPadding).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -TooltipView.labelPadding).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: TooltipView.labelPadding).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -TooltipView.labelPadding).isActive = true
        
        enableShadow(color: .black)
    }

    // MARK: - api

    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var attributedText: NSAttributedString? {
        get {
            return label.attributedText
        }
        set {
            label.attributedText = newValue
        }
    }

    // MARK: - layout

    override func layoutSubviews() {
        super.layoutSubviews()

        bubble.frame = bounds
        bubble.path = bubblePath().cgPath
        tip.frame = tipFrame()
        tip.path = tipPath().cgPath
    }

    // MARK: - bubble

    private func bubblePath() -> UIBezierPath {
        return UIBezierPath(roundedRect: bounds, cornerRadius: TooltipView.cornerRadius)
    }

    private let bubble: CAShapeLayer = {
        let bubble = CAShapeLayer()
        bubble.fillColor = TooltipView.color.cgColor
        return bubble
    }()

    // MARK: - tip

    enum TipPosition {
        case top, topLeft, topRight, bottom, bottomLeft, bottomRight, left, leftTop, leftBottom, right, rightTop, rightBottom
    }

    var position: TipPosition = .top

    private func tipFrame() -> CGRect {
        var frame = CGRect()

        // size
        switch position {
        case .top, .topLeft, .topRight, .bottom, .bottomLeft, .bottomRight:
            frame.size = CGSize(width: TooltipView.tipSize * 2, height: TooltipView.tipSize)
        case .left, .leftTop, .leftBottom, .right, .rightTop, .rightBottom:
            frame.size = CGSize(width: TooltipView.tipSize, height: TooltipView.tipSize * 2)
        }

        // position
        switch position {
        case .top, .topLeft, .topRight:
            frame.origin.y = -TooltipView.tipSize
        case .bottom, .bottomLeft, .bottomRight:
            frame.origin.y = bounds.maxY
        case .left, .leftTop, .leftBottom:
            frame.origin.x = -TooltipView.tipSize
        case .right, .rightTop, .rightBottom:
            frame.origin.x = bounds.maxX
        }
        switch position {
        case .top, .bottom:
            frame.origin.x = bounds.midX - TooltipView.tipSize
        case .topLeft, .bottomLeft:
            frame.origin.x = TooltipView.cornerRadius + TooltipView.padding
        case .topRight, .bottomRight:
            frame.origin.x = bounds.maxX - TooltipView.cornerRadius - TooltipView.padding - 2 * TooltipView.tipSize
        case .left, .right:
            frame.origin.y = bounds.midY - TooltipView.tipSize
        case .leftTop, .rightTop:
            frame.origin.y = TooltipView.cornerRadius + TooltipView.padding
        case .leftBottom, .rightBottom:
            frame.origin.y = bounds.maxY - TooltipView.cornerRadius - TooltipView.padding - 2 * TooltipView.tipSize
        }

        return frame
    }

    private func tipPath() -> UIBezierPath {
        let path = UIBezierPath()

        switch position {
        case .top, .topLeft, .topRight:
            path.move(to: CGPoint(x: 0, y: TooltipView.tipSize))
            path.addLine(to: CGPoint(x: 2 * TooltipView.tipSize, y: TooltipView.tipSize))
            path.addLine(to: CGPoint(x: TooltipView.tipSize, y: 0))
        case .bottom, .bottomLeft, .bottomRight:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 2 * TooltipView.tipSize, y: 0))
            path.addLine(to: CGPoint(x: TooltipView.tipSize, y: TooltipView.tipSize))
        case .left, .leftTop, .leftBottom:
            path.move(to: CGPoint(x: TooltipView.tipSize, y: 2 * TooltipView.tipSize))
            path.addLine(to: CGPoint(x: TooltipView.tipSize, y: 0))
            path.addLine(to: CGPoint(x: 0, y: TooltipView.tipSize))
        case .right, .rightTop, .rightBottom:
            path.move(to: CGPoint(x: 0, y: 2 * TooltipView.tipSize))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: TooltipView.tipSize, y: TooltipView.tipSize))
        }
        path.close()

        return path
    }

    private let tip: CAShapeLayer = {
        let tip = CAShapeLayer()
        tip.fillColor = TooltipView.color.cgColor
        return tip
    }()
}

