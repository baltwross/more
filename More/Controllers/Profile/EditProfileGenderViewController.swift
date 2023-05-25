//
//  EditProfileGenderViewController.swift
//  More
//
//  Created by Luko Gjenero on 16/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EditProfileGenderViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var male: EditProfileGenderItemView!
    @IBOutlet weak var female: EditProfileGenderItemView!
    @IBOutlet weak var custom: EditProfileGenderItemView!
    @IBOutlet weak var done: UIButton!
    
    var closeTap: ((_ gender: String?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        male.setup(for: .male)
        female.setup(for: .female)
        custom.setup(for: .custom)
        
        male.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maleTouch)))
        female.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(femaleTouch)))
        custom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(customTouch)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(startedEditing), name: UITextField.textDidBeginEditingNotification, object: nil)
        
        custom.done = { [weak self] in
            self?.closeTouch(nil)
        }
        
        done.enableShadow(color: .black)
    }
    
    @objc private func maleTouch() {
        male.isSelected = true
        female.isSelected = false
        custom.isSelected = false
        custom.closeKeyboard()
    }
    
    @objc private func femaleTouch() {
        male.isSelected = false
        female.isSelected = true
        custom.isSelected = false
        custom.closeKeyboard()
    }
    
    @objc private func customTouch() {
        male.isSelected = false
        female.isSelected = false
        custom.isSelected = true
    }
    
    @objc private func startedEditing(_ notice: Notification) {
        if let tf = notice.object as? UITextField {
            if tf.superview == custom || tf.superview?.superview == custom {
                customTouch()
            }
        }
        
        male.isSelected = false
        female.isSelected = false
        custom.isSelected = true
    }
    
    @IBAction func closeTouch(_ sender: Any?) {
        
        var gender: String? = nil
        if male.isSelected {
            gender = "male"
        } else if female.isSelected {
            gender = "female"
        } else if custom.isSelected {
            gender = custom.text
        }
        closeTap?(gender)
    }
    
    
    func setup(for profile: Profile) {
        if let gender = profile.gender {
            switch gender.lowercased() {
            case "male":
                male.isSelected = true
                female.isSelected = false
                custom.isSelected = false
                custom.setup(for: .custom, custom: nil)
            case "female":
                male.isSelected = false
                female.isSelected = true
                custom.isSelected = false
                custom.setup(for: .custom, custom: nil)
            default:
                male.isSelected = false
                female.isSelected = false
                custom.isSelected = true
                custom.setup(for: .custom, custom: gender)
            }
        } else {
            male.isSelected = false
            female.isSelected = false
            custom.isSelected = false
            custom.setup(for: .custom, custom: nil)
        }
    }

}
