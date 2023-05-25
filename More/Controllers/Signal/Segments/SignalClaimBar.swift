//
//  SignalClaimBar.swift
//  More
//
//  Created by Luko Gjenero on 15/01/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class SignalClaimBar: LoadableView {

    @IBOutlet private weak var ribbon: ExploreClaimRibbon!
    @IBOutlet private weak var shareButton: UIButton!
    
    var shareTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        shareButton.layer.cornerRadius = 26.5
        ribbon.type = .shortClaim
    }
    
    @IBAction private func shareTouch(_ sender: Any) {
        shareTap?()
    }
    
    
    

}
