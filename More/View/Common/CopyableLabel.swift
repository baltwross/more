//
//  CopyableLabel.swift
//  More
//
//  Created by Luko Gjenero on 30/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class CopyableLabel: UILabel {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            isHighlighted = true
            return true
        }
        return false
    }
    
    @objc override func copy(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = text
        isHighlighted = false
        resignFirstResponder()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFirstResponder {
            isHighlighted = false
            let menu = UIMenuController.shared
            menu.setMenuVisible(false, animated: true)
            menu.update()
            resignFirstResponder()
        } else if becomeFirstResponder() {
            let menu = UIMenuController.shared
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
            menu.update()
        }
    }

}
