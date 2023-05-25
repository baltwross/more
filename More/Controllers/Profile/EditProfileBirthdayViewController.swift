//
//  EditProfileBirthdayViewController.swift
//  More
//
//  Created by Luko Gjenero on 16/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EditProfileBirthdayViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var birthday: UIDatePicker!
    @IBOutlet weak var done: UIButton!
    
    var closeTap: ((_ birthday: Date)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        birthday.maximumDate = Date()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        done.enableShadow(color: .black, path: UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.frame.width, height: 60)).cgPath)
    }
    
    @IBAction func closeTouch(_ sender: Any) {
        closeTap?(birthday.date)
    }
    
    func setup(for profile: Profile) {
        var components = DateComponents()
        components.year = -18
        let years18 = Calendar.current.date(byAdding: components, to: Date())!
        birthday.date = profile.birthday ?? years18
    }

    @IBAction func doneTouch(_ sender: Any) {
        closeTap?(birthday.date)
    }
}
