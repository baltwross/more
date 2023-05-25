//
//  MoreCalloutView.swift
//  More
//
//  Created by Luko Gjenero on 09/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Mapbox

private let corner: CGFloat = 0
private let tipSize: CGFloat = 12

@IBDesignable
class MoreCalloutView: LoadableView, MGLCalloutView {
    
    var representedObject: MGLAnnotation = MorePointAnnotation() {
        didSet {
            title.text = representedObject.title!
            subTitle.text = representedObject.subtitle!
        }
    }
    
    var leftAccessoryView: UIView = UIView()
    
    var rightAccessoryView: UIView = UIView()
    
    var delegate: MGLCalloutViewDelegate?
    
    func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedRect: CGRect, animated: Bool) {

        var origin = CGPoint(x: rect.midX, y: rect.minY)
        let size = systemLayoutSizeFitting(constrainedRect.size, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .defaultLow)
        origin.x -= size.width * 0.5
        origin.y -= size.height
        frame = CGRect( origin: origin, size: size)
        alpha = 0
        
        view.addSubview(self)
        UIView.animate(
            withDuration: animated ? 0.3 : 0,
            animations: { [weak self] in
                self?.alpha = 1
            })
    }
    
    func dismissCallout(animated: Bool) {
        UIView.animate(
            withDuration: animated ? 0.3 : 0,
            animations: { [weak self] in
                self?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.removeFromSuperview()
            })
    }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    private let background: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    override func setupNib() {
        super.setupNib()
        
        backgroundColor = .white
        layer.insertSublayer(background, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = generatePath().cgPath
        background.path = path
        enableShadow(color: .black, path: path)
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
        path.addLine(to: CGPoint(x: frame.size.width - corner, y: 0.0))
        
        if corner > 0 {
            path.addArc(withCenter: CGPoint(x: frame.size.width - corner, y: corner), radius: corner, startAngle: CGFloat(-90).toRadians(), endAngle: CGFloat(0).toRadians(), clockwise: true)
        }
        
        path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height - corner - tipSize))
        
        if corner > 0 {
            path.addArc(withCenter: CGPoint(x: frame.size.width - corner, y: frame.size.height - corner - tipSize), radius: corner, startAngle: CGFloat(0).toRadians(), endAngle: CGFloat(90).toRadians(), clockwise: true)
        }
        
        path.addLine(to: CGPoint(x: frame.size.width/2 + tipSize, y: frame.size.height - tipSize))
        path.addLine(to: CGPoint(x: frame.size.width/2, y: frame.size.height))
        path.addLine(to: CGPoint(x: frame.size.width/2 - tipSize, y: frame.size.height - tipSize))
        path.addLine(to: CGPoint(x: corner, y: frame.size.height - tipSize))
        
        if corner > 0 {
            path.addArc(withCenter: CGPoint(x: corner, y: frame.size.height - corner), radius: corner, startAngle: CGFloat(90).toRadians(), endAngle: CGFloat(180).toRadians(), clockwise: true)
        }
        
        path.addLine(to: CGPoint(x: 0, y: corner))
        
        if corner > 0 {
            path.addArc(withCenter: CGPoint(x: corner, y: corner), radius: corner, startAngle: CGFloat(180).toRadians(), endAngle: CGFloat(270).toRadians(), clockwise: true)
        }
        path.close()
        
        return path
    }
    
}
