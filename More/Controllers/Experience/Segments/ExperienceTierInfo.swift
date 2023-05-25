//
//  ExperienceTierInfo.swift
//  More
//
//  Created by Luko Gjenero on 04/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceTierInfo: LoadableView {

    override func setupNib() {
        super.setupNib()
        
        if let view = subviews.first {
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 15
        }
    }

}
