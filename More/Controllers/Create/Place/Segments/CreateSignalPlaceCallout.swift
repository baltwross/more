//
//  CreateSignalPlaceCallout.swift
//  More
//
//  Created by Luko Gjenero on 14/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Mapbox

class CreateSignalPlaceCallout: UIView, MGLCalloutView {
    
    var representedObject: MGLAnnotation = MorePointAnnotation() {
        didSet {
            label.text = representedObject.title!
        }
    }
    
    var leftAccessoryView: UIView = UIView()
    var rightAccessoryView: UIView = UIView()
    var delegate: MGLCalloutViewDelegate?
    
    private let bubble: UIView = {
        let bubble = UIView()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.backgroundColor = .black
        bubble.layer.cornerRadius = 15
        bubble.layer.masksToBounds = true
        return bubble
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont(name: "Gotham-Bold", size: 14)!
        return label
    }()
    
    func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedRect: CGRect, animated: Bool) {
        
        var origin = CGPoint(x: rect.midX, y: rect.minY)
        let size = systemLayoutSizeFitting(constrainedRect.size, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .defaultLow)
        origin.x -= size.width * 0.5
        origin.y -= size.height + 12
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        enableShadow(color: .black, path: UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath)
    }
    
    private func setupUI() {
        addSubview(bubble)
        bubble.addSubview(label)
        
        bubble.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bubble.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bubble.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubble.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 15).isActive = true
        label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -15).isActive = true
        label.topAnchor.constraint(equalTo: bubble.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor).isActive = true
        
        heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}



