//
//  AlertMessageView.swift
//  More
//
//  Created by Luko Gjenero on 18/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SwiftMessages

class AlertMessageView: MessageView {

    @IBOutlet weak var content: AlertContentView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button = content.button
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        enableShadow(color: .black, path: UIBezierPath(rect: bounds).cgPath)
    }

}
