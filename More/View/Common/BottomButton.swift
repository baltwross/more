//
//  BottomButton.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class BottomButton: LoadableView {
    
    enum ButtonType {
        case dark, red
    }
    
    @IBOutlet private weak var button: UIButton!
    
    var tap: (()->())?
    
    var type: ButtonType = .dark {
        didSet {
            setup(enabled: !isDisabled)
        }
    }
    
    override func setupNib() {
        super.setupNib()
        setup(enabled: true)
    }
    
    private func setup(enabled: Bool) {
        if enabled {
            switch type {
            case .dark:
                button.setTitleColor(UIColor.whiteThree, for: .normal)
                button.setTitleColor(UIColor.darkGrey, for: .disabled)
                backgroundColor = .darkGrey
            case .red:
                button.setTitleColor(UIColor.whiteThree, for: .normal)
                button.setTitleColor(UIColor.whiteThree, for: .disabled)
                backgroundColor = .scarlet
            }
        } else {
            switch type {
            case .dark:
                button.setTitleColor(UIColor.whiteThree, for: .normal)
                button.setTitleColor(UIColor.darkGrey, for: .disabled)
                backgroundColor = .lightPeriwinkle
            case .red:
                button.setTitleColor(UIColor.whiteThree, for: .normal)
                button.setTitleColor(UIColor.whiteThree, for: .disabled)
                backgroundColor = UIColor.scarlet.withAlphaComponent(0.5)
            }
        }
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        tap?()
    }
    
    func setTitle(_ title: String) {
        button.setTitle(title, for: .normal)
    }
    
    var isDisabled: Bool = false {
        didSet {
            button.isEnabled = !isDisabled
            setup(enabled: !isDisabled)
        }
    }
    
}
