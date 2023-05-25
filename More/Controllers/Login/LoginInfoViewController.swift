//
//  LoginInfoViewController.swift
//  More
//
//  Created by Igor Ostriz on 18/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class LoginInfoViewController: BaseLoginViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var firstName: SkyFloatingLabelTextField!
    @IBOutlet weak var lastName: SkyFloatingLabelTextField!
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var nextButton: FancyNextButton!
    @IBOutlet weak var nextContainer: UIView!
    
    private let keyboardManager = KeyboardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController?.viewControllers.count == 0 {
            backButton.isHidden = true
        }
        
        keyboardManager.containerView = infoContainer
        // keyboardManager.manageTextField(firstName, withMaxLength: 0, showDone: false)
        if UIScreen.main.bounds.height <= 568.0 {
            // keyboardManager.manageTextField(lastName, withMaxLength: 0, showDone: false)
            keyboardManager.manageTextField(email, withMaxLength: 0, showDone: false)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(sender:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        for constraint in view.constraints {
            if constraint.firstAnchor == nextContainer.bottomAnchor ||
                constraint.secondAnchor == nextContainer.bottomAnchor {
                bottomContraint = constraint
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(check), name: UITextField.textDidChangeNotification, object: firstName)
        NotificationCenter.default.addObserver(self, selector: #selector(check), name: UITextField.textDidChangeNotification, object: lastName)
        NotificationCenter.default.addObserver(self, selector: #selector(check), name: UITextField.textDidChangeNotification, object: email)
        trackKeyboardAndPushUp()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func backTouch(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func nextTouch(_ sender: Any) {
        if let firstName = firstName.text, firstName.count > 0,
            let lastName = lastName.text, lastName.count > 0,
            let email = email.text, email.count > 0 {
            
            ProfileService.shared.updateInfo(firstName: firstName, lastName: lastName, email: email)
            nextView?()
        }
    }
    
    @objc private func onTap(sender: UITapGestureRecognizer){
        UIResponder.resignAnyFirstResponder()
    }
    
    @objc private func check() {
        if let firstName = firstName.text, firstName.count > 0,
            let lastName = lastName.text, lastName.count > 0,
            let email = email.text, email.count > 0 {
            nextButton.enableWithAnimation(true, false)
        } else {
            nextButton.enableWithAnimation(false, false)
        }
    }
}
