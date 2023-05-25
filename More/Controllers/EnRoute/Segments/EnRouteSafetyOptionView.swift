//
//  EnRouteSafetyOptionView.swift
//  More
//
//  Created by Luko Gjenero on 29/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EnRouteSafetyOptionView: LoadableView {

    enum OptionType {
        case cancel, issue, unsafe
    }
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    
    
    var type: OptionType = .cancel {
        didSet {
            update(for: type)
        }
    }
    
    private func update(for type: OptionType) {
        switch type {
        case .cancel:
            title.textColor = UIColor(red: 67, green: 74, blue: 81)
            title.text = "I WISH TO CANCEL"
            subtitle.text = "You changed your mind."
        case .issue:
            title.textColor = UIColor(red: 67, green: 74, blue: 81)
            title.text = "I HAVE AN ISSUE"
            subtitle.text = "You will be canceled and prompted to report an issue."
        case .unsafe:
            title.textColor = UIColor(red: 204, green: 0, blue: 4)
            title.text = "I FEEL UNSAFE"
            subtitle.text = "You will be canceled immediately."
        }
    }
}
