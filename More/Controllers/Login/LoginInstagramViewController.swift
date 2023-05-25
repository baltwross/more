//
//  LoginInstagramViewController.swift
//  More
//
//  Created by Luko Gjenero on 30/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class LoginInstagramViewController: BaseLoginViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var instagram: SkyFloatingLabelTextField!
    @IBOutlet weak var nextButton: FancyNextButton!
    @IBOutlet weak var nextContainer: UIView!
    
    private var keyboardManager = KeyboardManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController?.viewControllers.count == 0 {
            backButton.isHidden = true
        }
        
        keyboardManager.containerView = view
        keyboardManager.manageTextField(instagram, withMaxLength: 0, showDone: false)
        
        nextButton.enableWithAnimation(false, false)
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(check), name: UITextField.textDidChangeNotification, object: instagram)
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
        if let instagram = instagram.text, instagram.count > 0 {
            
            ProfileService.shared.updateInstagram(instagram)
            nextView?()
        }
    }
    
    @objc private func onTap(sender: UITapGestureRecognizer){
        UIResponder.resignAnyFirstResponder()
    }
    
    @objc private func check() {
        if let instagram = instagram.text, instagram.count > 0 {
            nextButton.enableWithAnimation(true, false)
        } else {
            nextButton.enableWithAnimation(false, false)
        }
    }
    
}
