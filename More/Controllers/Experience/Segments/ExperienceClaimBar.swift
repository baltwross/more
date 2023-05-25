//
//  ExperienceClaimBar.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceClaimBar: LoadableView {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var buttonTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        buttonTap?()
    }

}
