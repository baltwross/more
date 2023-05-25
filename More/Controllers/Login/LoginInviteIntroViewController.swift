//
//  LoginRequestInviteViewController.swift
//  More
//
//  Created by Igor Ostriz on 11/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//


import UIKit


class LoginInviteIntroViewController: BaseLoginViewController {

    @IBOutlet private weak var inviteLongView: InviteShortView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inviteLongView.onAccept = { [weak self] in
            ProfileService.shared.updateTerms(true)
            self?.nextView?()
        }
        
        inviteLongView.onReject = {
            // TODO: What to do?
        }
        
        UIResponder.resignAnyFirstResponder()
    }
}
