//
//  AlertTextAndDismissMessageView.swift
//  More
//
//  Created by Luko Gjenero on 14/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SwiftMessages

class AlertTextAndDismissMessageView: MessageView {
    
    @IBOutlet weak var content: AlertTextAndDismissContentView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button = content.dismiss
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        enableShadow(color: .black, path: UIBezierPath(rect: bounds).cgPath)
    }

}
