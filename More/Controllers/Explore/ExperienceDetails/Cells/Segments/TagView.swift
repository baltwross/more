//
//  TagView.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let corner: CGFloat = 4
private let tipSize: CGFloat = 7

@IBDesignable
class TagView: LoadableView {

    static let height: CGFloat = 40
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var count: UILabel!

    private let background: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    override func setupNib() {
        super.setupNib()
        
        layer.insertSublayer(background, at: 0)
        enableShadow(color: .black)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        background.path = generatePath().cgPath
    }
    
    override var backgroundColor: UIColor? {
        get {
            if let bg = background.fillColor {
                return UIColor(cgColor: bg)
            }
            return nil
        }
        set {
            background.fillColor = newValue?.cgColor
        }
    }
    
    private func generatePath() -> UIBezierPath {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: corner, y: 0.0))
        
        path.addLine(to: CGPoint(x: frame.size.width/2 - tipSize, y: 0))
        path.addLine(to: CGPoint(x: frame.size.width/2, y: -tipSize))
        path.addLine(to: CGPoint(x: frame.size.width/2 + tipSize, y: 0))
        
        path.addLine(to: CGPoint(x: frame.size.width - corner, y: 0.0))
        
        path.addArc(withCenter: CGPoint(x: frame.size.width - corner, y: corner), radius: corner, startAngle: CGFloat(-90).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: true)
        path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height - corner))
        path.addArc(withCenter: CGPoint(x: frame.size.width - corner, y: frame.size.height - corner), radius: corner, startAngle: CGFloat(0).toRadians(), endAngle: CGFloat(90).toRadians(), clockwise: true)
        
        path.addLine(to: CGPoint(x: corner, y: frame.size.height))
        path.addArc(withCenter: CGPoint(x: corner, y: frame.size.height - corner), radius: corner, startAngle: CGFloat(90).toRadians(), endAngle: CGFloat(180).toRadians(), clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: corner))
        path.addArc(withCenter: CGPoint(x: corner, y: corner), radius: corner, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(270).toRadians(), clockwise: true)
        path.close()
        
        return path
    }
    
    func setup(label: String, count: Int) {
        self.label.text = label
        self.count.text = "\(count)"
    }
    
    class func size(label: String, count: Int, in size: CGSize) -> CGSize {
        
        let labelFont = UIFont(name: "Avenir-Black", size: 15) ?? UIFont.systemFont(ofSize: 15)
        let countFont = UIFont(name: "Gotham-Black", size: 9) ?? UIFont.systemFont(ofSize: 11)
        
        let labelWidht = label.width(withConstrainedHeight: size.height, font: labelFont)
        let countWidht = "\(count)".width(withConstrainedHeight: size.height, font: countFont)
        
        return CGSize(width: 16 + labelWidht + 16 + countWidht + 16, height: TagView.height)
    }
    

}
