//
//  EditProfileMomentView.swift
//  More
//
//  Created by Luko Gjenero on 30/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EditProfileMomentView: LoadableView {

    @IBOutlet private weak var titleLabel: SpecialLabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    @IBInspectable var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    func setup(subtitle: String) {
        subtitleLabel.text = subtitle
    }

}
