//
//  EditProfileInfoViewController.swift
//  More
//
//  Created by Luko Gjenero on 16/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EditProfileInfoViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var firstNameUnderline: UIView!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var lastNameUnderline: UIView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var emailUnderline: UIView!
    
    private let keyboardManager = KeyboardManager()
    
    var closeTap: ((_ firstName: String?, _ lastName: String?, _ email: String?)->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameUnderline.alpha = 0.4
        lastNameUnderline.alpha = 0.4
        emailUnderline.alpha = 0.4
        
        let done = KeyboardManager.createToolbar()
        done.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        
        firstName.inputAccessoryView = done
        lastName.inputAccessoryView = done
        email.inputAccessoryView = done
        
        if UIScreen.main.bounds.height <= 568.0 {
            keyboardManager.manageTextField(email, withMaxLength: 0, showDone: false)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(startedEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endedEditing(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
    }
    
    @IBAction func closeKeyboard() {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
        email.resignFirstResponder()
        closeTap?(firstName.text, lastName.text, email.text)
    }
    
    @IBAction func closeTouch(_ sender: Any) {
        closeKeyboard()
    }
   
    @objc private func startedEditing(_ notice: Notification) {
        if notice.object as? UITextField == firstName {
            firstNameUnderline.alpha = 1
        } else if notice.object as? UITextField == lastName {
            lastNameUnderline.alpha = 1
        } else if notice.object as? UITextField == email {
            emailUnderline.alpha = 1
        }
    }
    
    @objc private func endedEditing(_ notice: Notification) {
        if notice.object as? UITextField == firstName {
            firstNameUnderline.alpha = 0.4
        } else if notice.object as? UITextField == lastName {
            lastNameUnderline.alpha = 0.4
        } else if notice.object as? UITextField == email {
            emailUnderline.alpha = 0.4
        }
    }
    
    func setup(for profile: Profile) {
        firstName.text = profile.firstName
        lastName.text = profile.lastName
        email.text = profile.email
    }
    
}
