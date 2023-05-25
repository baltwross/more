//
//  EditProfileMomentViewController.swift
//  More
//
//  Created by Luko Gjenero on 30/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EditProfileMomentViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var momentView: AutoGrowingTextView!
    @IBOutlet weak var momentUnderline: UIView!
    
    var closeTap: ((_ quote: String?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        momentUnderline.alpha = 0.4
        
        let done = KeyboardManager.createToolbar()
        done.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        
        momentView.inputAccessoryView = done
        
        momentView.placeholderLabel.font = momentView.font
        momentView.placeholderLabel.textColor = momentView.textColor?.withAlphaComponent(0.4)
        momentView.placeholderLabel.text = "One of my best memories..."
        
        NotificationCenter.default.addObserver(self, selector: #selector(startedEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endedEditing(_:)), name: UITextView.textDidEndEditingNotification, object: nil)
        
        for constraint in view.constraints {
            if constraint.firstAnchor == contentView.bottomAnchor ||
                constraint.secondAnchor == contentView.bottomAnchor {
                bottomContraint = constraint
                break
            }
        }
        trackKeyboardAndPushUp()
    }
    
    @IBAction func closeKeyboard() {
        momentView.resignFirstResponder()
        closeTap?(momentView.text)
    }
    
    @IBAction func closeTouch(_ sender: Any) {
        momentView.resignFirstResponder()
        closeTap?(momentView.text)
    }
    
    @objc private func startedEditing(_ notice: Notification) {
        if notice.object as? UITextView == momentView {
            momentUnderline.alpha = 1
            momentView.maxHeightConstraint?.constant = contentView.frame.height - 52
            momentView.text = momentView.text
        }
    }
    
    @objc private func endedEditing(_ notice: Notification) {
        if notice.object as? UITextView == momentView {
            momentUnderline.alpha = 0.4
            momentView.maxHeightConstraint?.constant = contentView.frame.height - 52
            momentView.text = momentView.text
        }
    }
    
    func setup(for profile: Profile) {
        momentView.text = profile.memories
    }

}
