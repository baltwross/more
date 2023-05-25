//
//  ExperienceStartBar.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceStartBar: LoadableView {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    
    var startTap: (()->())?
    var activateTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = 25
    }
    
    func setup(for experience: Experience) {
        // nop
    }
    
    @IBAction private func startTouch(_ sender: Any) {
        startTap?()
    }
}
