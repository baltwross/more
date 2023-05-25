//
//  ExploreCreateView.swift
//  More
//
//  Created by Luko Gjenero on 29/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExploreCreateView: LoadableView {

    @IBOutlet private weak var outline: UIView!
    @IBOutlet private weak var signalOutline: UIView!
    
    var tap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        outline.layer.borderColor = UIColor.white.cgColor
        outline.layer.borderWidth = 1
        outline.layer.cornerRadius = 26.5
        outline.layer.masksToBounds = true
        
        signalOutline.layer.shadowColor = UIColor.charcoalGrey.withAlphaComponent(0.1).cgColor
        signalOutline.layer.shadowOffset = CGSize(width: 0, height: 0)
        signalOutline.layer.shadowRadius = 10
        signalOutline.layer.shadowOpacity = 1
        signalOutline.layer.cornerRadius = 15
        // signalOutline.layer.masksToBounds = true
        
        outline.isUserInteractionEnabled = true
        outline.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
    }
    
    @objc private func tapped() {
        tap?()
    }
    
}
