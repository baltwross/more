//
//  LoginEnterCodeViewController.swift
//  More
//
//  Created by Igor Ostriz on 11/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import PinCodeTextField
import UIKit
import MBProgressHUD

class LoginEnterCodeViewController: UIViewController, PinCodeTextFieldDelegate, UITextFieldDelegate {

    @IBOutlet private weak var pinCodeTextField: PinCodeTextField!
    @IBOutlet private weak var nextButton: FancyNextButton!
    @IBOutlet private weak var resendButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    private var error: Bool = false
    
    var login: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pinCodeTextField.delegate = self
        pinCodeTextField.keyboardType = .numberPad
        pinCodeTextField.font = UIFont(name: "DIN-Regular", size: 30) ?? UIFont.systemFont(ofSize: 30)
        pinCodeTextField.textContentType = .oneTimeCode
        
        resendButton.alpha = 0
        errorLabel.isHidden = true
    }
    
    private var isFirst = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pinCodeTextField.becomeFirstResponder()
        
        guard isFirst else { return }
        isFirst = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
            guard self != nil else { return }
            UIView.animate(withDuration: 0.3, animations: {
                self?.resendButton.alpha = 1
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    /*!
     @brief It shows MBProgressHUD.
     @discussion It displays MBProgressHUD to the specific view.
     @param view The view to be displayed MBProgressHUD
     @return
     */
    func showHUD(view: UIView?, label: String = "Loading...") -> Void {
        
        var v: UIView? = view
        if v == nil {
            v = UIApplication.shared.delegate?.window!
        }
        
        let loadingHud = MBProgressHUD.showAdded(to: v!, animated: true)
        loadingHud.bezelView.backgroundColor = UIColor.black
        loadingHud.contentColor = UIColor.white
        loadingHud.label.text = NSLocalizedString(label, comment: "")
    }
    
    /*!
     @brief It hiddens MBProgressHUD.
     @discussion It hiddens MBProgressHUD from the specific view.
     @param view The view the MBProgressHUD is dismissed
     @return
     */
    func hideHUD(view: UIView?) -> Void {
        var v: UIView? = view
        if v == nil {
            v = UIApplication.shared.delegate?.window!
        }
        MBProgressHUD.hide(for: v!, animated: true)
    }
    

    @IBAction func onResendButton(_ sender: UIButton) {
        
        let phoneNumber: String = ProfileService.shared.profile?.phoneNumber ?? ""
        let formattedNumber: String = ProfileService.shared.profile?.formattedPhoneNumber ?? ""

        showHUD(view: nil, label: "Resending to: \(formattedNumber)")
        
        ProfileService.shared.verifyPhoneNumber(phoneNumber: phoneNumber, formattedPhoneNumber: formattedNumber) { [weak self] (success, errorMsg) in
            
            self?.hideHUD(view: nil)
            self?.pinCodeTextField.becomeFirstResponder()
            
            if !success {
                self?.errorAlert(text: errorMsg ?? "Unknown error")
                return
            }
        }
    }
    
    @IBAction private func onButton() {
        nextButton.enableWithAnimation(true, true)

        let verificationCode = pinCodeTextField.text!
        ProfileService.shared.signIn(verificationCode: verificationCode) { [weak self] (success, errorMsg) in
            DispatchQueue.main.async {
                
                self?.nextButton.enableWithAnimation(true, false)
                
                if !success {
                    self?.error(errorMsg ?? "Unknown Error")
                    return
                }
                
                self?.login?()
            }
        }
    }
    
    // MARK: - text change
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        textChanged(to: textField.text ?? "")
    }
    
    private func textChanged(to text: String) {
        if text.count < 6 {
            nextButton.enableWithAnimation(false, false)
        } else {
            nextButton.enableWithAnimation(true, false)
        }
        
        if error {
            resetError()
        }
        
        UIView.animate(withDuration: 0.35) {
            self.nextButton.alpha = text.count > 0 ? 1 : 0
        }
    }
    
    // MARK: - flow
    
    func presentInviteIntro() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let rootViewController = appDelegate.window?.rootViewController
        
        let vc = LoginInviteIntroViewController.create()
        vc!.modalTransitionStyle = .crossDissolve
        rootViewController?.present(vc!, animated: true, completion: nil)
    }

    // MARK - error
    
    func resetError() {
        error = false
        errorLabel.isHidden = true
        pinCodeTextField.updatedUnderlineColor = UIColor(red: 218, green: 221, blue: 227)
    }
    
    func error(_ errorMsg: String ) {
        error = false
        errorLabel.isHidden = false
        errorLabel.text = errorMsg
        pinCodeTextField.updatedUnderlineColor = .red
    }
    
}








