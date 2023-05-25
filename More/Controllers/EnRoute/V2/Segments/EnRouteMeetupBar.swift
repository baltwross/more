//
//  EnRouteMeetupBar.swift
//  More
//
//  Created by Luko Gjenero on 20/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EnRouteMeetupBar: LoadableView {

    enum BarType {
        case arrive, met
    }
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    var tap: (()->())?
    
    var type: BarType = .arrive {
        didSet {
            switch type {
            case .arrive:
                icon.image = UIImage(named: "did-you-arrive")
            case .met:
                icon.image = UIImage(named: "did-you-meet")
            }
        }
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        tap?()
    }
    
    func setup(text: String) {
        label.text = text
    }

}
