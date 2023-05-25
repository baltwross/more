//
//  AlertTextAndDismissContentView.swift
//  More
//
//  Created by Luko Gjenero on 14/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class AlertTextAndDismissContentView: LoadableView {

    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var dismiss: UIButton!
    
    func setup(message: String) {
        self.message.text = message
    }

}
