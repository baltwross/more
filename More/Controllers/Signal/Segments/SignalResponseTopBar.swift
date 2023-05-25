//
//  SignalResponseTopBar.swift
//  More
//
//  Created by Luko Gjenero on 04/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class SignalResponseTopBar: LoadableView {

    @IBOutlet private weak var countdown: CountdownLabel!
    @IBOutlet private weak var down: UIButton!
    @IBOutlet private weak var label: UILabel!
        
    var downTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        countdown.setDateFormat("m:ss")
        countdown.refreshIterval = 0.5
    }
    
    func setup(signal: SignalViewModel, request: RequestViewModel) {
        countdown.countdown(to: request.expiresAt)
        label.text = signal.quote
    }
    
    @IBAction func downTouch(_ sender: Any) {
        downTap?()
    }

}
