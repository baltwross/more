//
//  ExperienceRequestViewController.swift
//  More
//
//  Created by Luko Gjenero on 03/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ExperienceRequestViewController: UIViewController {

    var done: (()->())?
    
    var share: (()->())?
    
    var error: ((_ errorMsg: String?)->())?
    
    func fullyCollapse(animated: Bool = true) { }
    
    var isCollapsed: Bool {
        return false
    }
    
    func setup(for experience: Experience) { }
}
