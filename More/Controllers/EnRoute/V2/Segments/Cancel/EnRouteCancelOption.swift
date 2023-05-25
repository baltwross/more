//
//  EnRouteCancelOption.swift
//  More
//
//  Created by Luko Gjenero on 09/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EnRouteCancelOption: LoadableView {
    
    enum Option {
        case cancel, issue, unsafe
    }
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subTitle: UILabel!
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var button: UIButton!
    
    var option: Option = .cancel {
        didSet {
            updateOption()
        }
    }
    
    var tap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        updateOption()
    }
    
    private func updateOption() {
        title.textColor = .charcoalGrey
        switch option {
        case .cancel:
            title.text = "I WISH TO CANCEL"
            subTitle.text = "You changed your mind."
        case .issue:
            title.text = "I HAVE AN ISSUE"
            subTitle.text = "You’ll be prompted to report an issue."
        case .unsafe:
            title.textColor = .scarlet
            title.text = "I FEEL UNSAFE"
            subTitle.text = "You will be canceled immediately."
        }
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        tap?()
    }
    
}
