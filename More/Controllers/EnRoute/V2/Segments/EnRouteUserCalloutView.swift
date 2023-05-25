//
//  EnRouteUserCalloutView.swift
//  More
//
//  Created by Luko Gjenero on 18/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Mapbox

private let circleRadius: CGFloat = 22.5
private let triangleHeight: CGFloat = 5
private let triangleWidth: CGFloat = 5
private let circleBorder: CGFloat = 2

class EnRouteUserCalloutView: UIView, MGLCalloutView {
    
    var representedObject: MGLAnnotation = MorePointAnnotation() {
        didSet {
            if let moreObject = representedObject as? MorePointAnnotation {
                avatar.sd_progressive_setImage(with: URL(string: moreObject.user?.avatar ?? ""))
                
                let type: SignalType = moreObject.type ?? .chill
                bubble.colors = [type.gradient.0.cgColor, type.gradient.1.cgColor]
            }
        }
    }
    
    func setupForMe(_ type: SignalType) {
        let avatarUrl = ProfileService.shared.profile?.images?.first?.url ?? ""
        avatar.sd_progressive_setImage(with: URL(string: avatarUrl))
        
        bubble.colors = [type.gradient.0.cgColor, type.gradient.1.cgColor]
    }
    
    var leftAccessoryView: UIView = UIView()
    var rightAccessoryView: UIView = UIView()
    var delegate: MGLCalloutViewDelegate?
    
    private let bubble: CAGradientLayer = {
        let shape = CAShapeLayer()
        
        let frame = CGRect(origin: .zero, size: CGSize(width: circleRadius * 2, height: circleRadius * 2 + triangleHeight))
        let angle = asin(triangleWidth/circleRadius)
        let triangleHeightOffset = (1 - cos(angle)) * circleRadius
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: circleRadius, y: circleRadius * 2 + triangleHeight))
        path.addArc(
            withCenter: CGPoint(x: circleRadius, y: circleRadius),
            radius: circleRadius,
            startAngle: CGFloat.pi * 0.5 + angle,
            endAngle: CGFloat.pi * 2.5 - angle,
            clockwise: true)
        path.addLine(to: CGPoint(x: circleRadius, y: circleRadius * 2 + triangleHeight))
        path.close()
        
        shape.fillColor = UIColor.white.cgColor
        shape.path = path.cgPath
        shape.frame = frame
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 1.0);
        gradient.endPoint = CGPoint(x: 0.5, y: 0.0);
        gradient.frame = frame
        
        gradient.mask = shape
        
        return gradient
    }()
    
    private let avatar: AvatarImage = {
        let avatar = AvatarImage()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = .clear
        return avatar
    }()
    
    func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedRect: CGRect, animated: Bool) {
        
        var origin = CGPoint(x: rect.midX, y: rect.minY)
        let size = systemLayoutSizeFitting(constrainedRect.size, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .defaultLow)
        origin.x -= size.width * 0.5
        origin.y -= size.height + 12
        frame = CGRect(origin: origin, size: size)
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
        layer.insertSublayer(bubble, at: 0)
        addSubview(avatar)
        
        avatar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: circleBorder).isActive = true
        avatar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -circleBorder).isActive = true
        avatar.topAnchor.constraint(equalTo: topAnchor, constant: circleBorder).isActive = true
        avatar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -triangleHeight - circleBorder).isActive = true
        // avatar.isHidden = true
        
        widthAnchor.constraint(equalToConstant: circleRadius * 2).isActive = true
        heightAnchor.constraint(equalToConstant: circleRadius * 2 + triangleHeight).isActive = true
    }
}




