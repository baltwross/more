//
//  EnRouteSafetyCancelledView.swift
//  More
//
//  Created by Luko Gjenero on 29/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EnRouteSafetyCancelledView: LoadableView {

    enum OptionType {
        case cancel, issue, unsafe
    }
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    var type: OptionType = .cancel {
        didSet {
            update(for: type)
        }
    }
    
    var buttonTap: (()->())?
    
    private func update(for type: OptionType) {
        switch type {
        case .cancel:
            button.backgroundColor = UIColor(red: 40, green: 40, blue: 43)
            button.setTitle("KEEP EXPLORING", for: .normal)
            label.text = "Your Time has been cancelled. Next time, please don't Request or Accept Times if you're unsure."
        case .issue:
            button.backgroundColor = UIColor(red: 40, green: 40, blue: 43)
            button.setTitle("REPORT ISSUE", for: .normal)
            label.text = "Your Time has been cancelled. Please let us know your issue so we can investigate."
        case .unsafe:
            button.backgroundColor = UIColor(red: 150, green: 30, blue: 22)
            button.setTitle("DIAL 911", for: .normal)
            label.text = "Your Time has been cancelled. If this is an emergency, please dial 911 immediately."
        }
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        buttonTap?()
    }
}
