//
//  LoginEnterPhoneViewController.swift
//  More
//
//  Created by Igor Ostriz on 02/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import CountryPickerView
import Firebase
import libPhoneNumber_iOS
import Lottie
import SkyFloatingLabelTextField
import SafariServices

class LoginEnterPhoneViewController: UIViewController, CountryPickerViewDelegate {

    @IBOutlet private weak var countryPhoneCodeLabel: UILabel!
    @IBOutlet private weak var phoneTextField: SkyFloatingLabelTextField!
    @IBOutlet private weak var nextButton: FancyNextButton!
    @IBOutlet weak var legal: UITextViewNoPadding!
    
    let countryPicker: CountryPickerView! = CountryPickerView()
    var loadingAnimation: LottieAnimationView?
    
    var rawPhoneNumber: String? {
        var newString = phoneTextField.text?.trimmingCharacters(in: .whitespaces)
        if newString?.first != "+" {
            newString = countryPicker.selectedCountry.phoneCode + (newString ?? "")
        }
        return newString
    }
    
    static func create() -> LoginEnterPhoneViewController? {
        let storyboard = UIStoryboard.init(name: Storyboard.login, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginEnterPhoneID") as! LoginEnterPhoneViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryPicker.showPhoneCodeInView = true
        countryPicker.showCountryCodeInView = false
        countryPicker.flagImageView.isHidden = true
        countryPicker.delegate = self

        countryPhoneCodeLabel.text = countryPicker.selectedCountry.phoneCode
        
        phoneTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        countryPhoneCodeLabel.addGestureRecognizer(tap)
        
        setupLegalText()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIResponder.resignAnyFirstResponder()
    }

    
    @IBAction private func onButton() {
        checkPhoneWithPhoneProvider()
    }
    
    @objc func onTap(sender: UITapGestureRecognizer) {
        countryPicker.showCountriesList(from: self)
    }
 
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        countryPhoneCodeLabel.text = country.phoneCode
    }
    
    func verifyPhone(_ phoneString: String?) -> String? {
        
        UIView.animate(withDuration: 0.35) {
            self.nextButton.alpha = phoneString!.count > 0 ? 1 : 0
        }
        
        do {
            let putil = NBPhoneNumberUtil.sharedInstance();
            let n = try putil?.parse(phoneString, defaultRegion:nil)
            
            let phone = try putil?.format(n, numberFormat: NBEPhoneNumberFormat.NATIONAL)
            
            if putil?.isValidNumber(n) == true {
                nextButton.enableWithAnimation(true, false)
            }
            else {
                nextButton.enableWithAnimation(false, false)

            }
            
            return phone
        }
        catch {
            return nil
        }

    }
    
    func checkPhoneWithPhoneProvider() {
        
        nextButton.enableWithAnimation(true, true)
    
        let phoneNumber = rawPhoneNumber!
        let formattedPhoneNumber = phoneTextField.text!
        
        ProfileService.shared.verifyPhoneNumber(phoneNumber: phoneNumber, formattedPhoneNumber: formattedPhoneNumber) { [weak self] (success, errorMsg) in
            
            self?.nextButton.enableWithAnimation(true, false)
            if !success {
                self?.errorAlert(text: errorMsg ?? "Unknown error")
                return
            }
            
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "EnterCode", sender: nil)
            }
        }
    }
    
    private func setupLegalText() {
        
        let text = NSMutableAttributedString()
        
        let gray = UIColor(red: 124, green: 139, blue: 155)
        let blue = UIColor(red: 2, green: 202, blue: 255)
        
        let font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        let linkFont = UIFont(name: "Avenir-Heavy", size: 14) ?? UIFont.systemFont(ofSize: 14)
        
        var part = NSAttributedString(
            string: "By signing up with your phone number, you acknowledge that you have read the ",
            attributes: [NSAttributedString.Key.foregroundColor : gray,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        part = NSAttributedString(
            string: "Privacy Policy",
            attributes: [NSAttributedString.Key.foregroundColor : blue,
                         NSAttributedString.Key.font : linkFont,
                         NSAttributedString.Key.link : Urls.privacy])
        text.append(part)
        
        part = NSAttributedString(
            string: " and agreed to the ",
            attributes: [NSAttributedString.Key.foregroundColor : gray,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        part = NSAttributedString(
            string: "Terms of Service",
            attributes: [NSAttributedString.Key.foregroundColor : blue,
                         NSAttributedString.Key.font : linkFont,
                         NSAttributedString.Key.link : Urls.terms])
        text.append(part)
        
        part = NSAttributedString(
            string: ".",
            attributes: [NSAttributedString.Key.foregroundColor : gray,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        legal.attributedText = text
        legal.dataDetectorTypes = .all
        legal.delegate = self
    }
}

extension LoginEnterPhoneViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let nsString = textField.text as NSString?
        var newString = nsString?.replacingCharacters(in: range, with: string)
        newString = newString?.trimmingCharacters(in: .whitespaces)
        if newString?.first != "+" {
            newString = countryPicker.selectedCountry.phoneCode + (newString ?? "")
        }
        
        
        
        guard let replString = verifyPhone(newString) else {
            return true
        }
        
        textField.text = replString
        
        return false
    }
    
}

extension LoginEnterPhoneViewController: UITextViewDelegate, SFSafariViewControllerDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        let vc = SFSafariViewController(url: URL)
        vc.delegate = self
        present(vc, animated: true)
        
        return false
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}



