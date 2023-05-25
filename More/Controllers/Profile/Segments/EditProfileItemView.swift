//
//  EditProfileItemView.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EditProfileItemView: LoadableView {

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
    
    var disabled: Bool = false {
        didSet {
            if disabled {
                subtitleLabel.textColor = UIColor(rgb: 0xbfc3ca)
            } else {
                subtitleLabel.textColor = UIColor(rgb: 0x434a51)
            }
        }
    }

}
