//
//  FancyNextBotton.swift
//  More
//
//  Created by Igor Ostriz on 05/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//


import UIKit
import Lottie

extension CGFloat {
    static let arrowSize: CGFloat = 27.5
    static let nextButtonSize: CGFloat = 55
}

@IBDesignable
class FancyNextButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private var arrowImageView: UIImageView?
    
    func initialize() {
        backgroundColor = UIColor.init(rgb: 0xDADDE3)
        
        arrowImageView = UIImageView(image: UIImage(named: "arrow-right"))
        arrowImageView!.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView!.contentMode = .scaleAspectFill
        addSubview(arrowImageView!)
        arrowImageView!.widthAnchor.constraint(equalToConstant: CGFloat.arrowSize).isActive = true
        arrowImageView!.heightAnchor.constraint(equalToConstant: CGFloat.arrowSize).isActive = true
        arrowImageView!.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        arrowImageView!.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        layer.cornerRadius = bounds.size.width / 2
        layer.masksToBounds = true

    }

    private func lottieViewSetup() -> LottieAnimationView {
        
        let animationView = LottieAnimationView(name: "loading")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.8
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(animationView)        
        animationView.widthAnchor.constraint(equalToConstant: CGFloat.arrowSize * 1.5).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: CGFloat.arrowSize * 1.5).isActive = true
        animationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        animationView.isUserInteractionEnabled = true

        return animationView
    }
    

    func darkTheme(_ on:Bool) {
        if on {
            backgroundColor = UIColor.init(rgb: 0x28282B)
            arrowImageView?.image = UIImage(named: "arrow-right-active")
        }
        else {
            backgroundColor = UIColor.init(rgb: 0xDADDE3)
            arrowImageView?.image = UIImage(named: "arrow-right")
        }
    }
    
    
    func enableWithAnimation(_ enable: Bool, _ animation: Bool) {
        
        var lotv: LottieAnimationView?
        
        for subv in subviews {
            if let lo = subv as? LottieAnimationView {
                lotv = lo
            }
        }
        
        isEnabled = enable
        // check if already has view
        
        darkTheme(enable)
        arrowImageView?.isHidden = animation
        
       
        if animation {
            isEnabled = false
            lotv = lotv ?? lottieViewSetup()
            lotv?.play()
        }
        else {
            if lotv != nil {
                lotv?.stop()
                lotv?.removeFromSuperview()
            }
        }
    }
}
