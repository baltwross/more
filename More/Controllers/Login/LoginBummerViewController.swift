//
//  LoginBummerViewController.swift
//  More
//
//  Created by Luko Gjenero on 30/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class LoginBummerViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var firstName: UITextField!
    @IBOutlet private weak var lastName: UITextField!
    @IBOutlet private weak var email: UITextField!
    @IBOutlet private weak var submit: UIButton!
    @IBOutlet private weak var signedUpView: UIView!
    
    private let keyboardManager = KeyboardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardManager.containerView = view
        let tfs: [UITextField] = [firstName, lastName, email]
        for tf in tfs {
            tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 53))
            tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 53))
            keyboardManager.manageTextField(tf, withMaxLength: 0, showDone: true)
        }

        setDark(false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textUpdated), name: UITextField.textDidChangeNotification, object: nil)
        
        if let firstName = ProfileService.shared.profile?.firstName, firstName.count > 0,
            let lastName = ProfileService.shared.profile?.lastName, lastName.count > 0,
            let email = ProfileService.shared.profile?.email, email.count > 0 {
            signedUpView.isHidden = false
        } else {
            signedUpView.isHidden = true
            firstName.text = ProfileService.shared.profile?.firstName
            lastName.text = ProfileService.shared.profile?.lastName
            email.text = ProfileService.shared.profile?.email
        }
    }
    
    @IBAction private func submitTouch(_ sender: Any) {
        
        guard
            let firstName = ProfileService.shared.profile?.firstName, firstName.count > 0,
            let lastName = ProfileService.shared.profile?.lastName, lastName.count > 0,
            let email = ProfileService.shared.profile?.email, email.count > 0
            else { return }
        
        PushNotificationService.shared.requestPersmissions { [weak self] in
            ProfileService.shared.updateInfo(firstName: firstName, lastName: lastName, email: email)
            DispatchQueue.main.async {
                self?.signedUpView.isHidden = false
            }
        }
    }
    
    @objc private func textUpdated() {
        let tfs: [UITextField] = [firstName, lastName, email]
        let dark = tfs.reduce(true) { (previous, tf) -> Bool in
            return previous && (tf.text?.count ?? 0) > 0
        }
        setDark(dark)
    }
    
    func setDark(_ dark: Bool) {
        if dark {
            submit.isUserInteractionEnabled = true
            submit.backgroundColor = Colors.previewDarkBackground
            submit.setTitleColor(Colors.previewDarkText, for: .normal)
        } else {
            submit.isUserInteractionEnabled = false
            submit.backgroundColor = Colors.previewLightBackground
            submit.setTitleColor(Colors.previewLightText, for: .normal)
        }
    }
    

    

}
