//
//  InviteLongViewController.swift
//  More
//
//  Created by Igor Ostriz on 18/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class InviteLongView: LoadableView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var rejectButton: UIButton!
    @IBOutlet private weak var acceptButton: UIButton!
    
    var onAccept: (() -> Void)? = nil
    var onReject: (() -> Void)? = nil
    
    override func setupNib() {
        super.setupNib()
        
        rejectButton.layer.cornerRadius = 26.5
        rejectButton.layer.borderColor = UIColor(red: 244, green: 244, blue: 244).cgColor
        rejectButton.layer.borderWidth = 1
        
        acceptButton.layer.cornerRadius = 26.5
        
        if let referral = ProfileService.shared.profile?.referral {
            
            titleLabel.isHidden = true
            subTitleLabel.isHidden = true
            
            ProfileService.shared.loadProfile(withId: referral) { [weak self] (profile, errorMsg) in
                
                if let profile = profile {
                    
                    if profile.id == Id.More {
                        self?.titleLabel.text = "You’ve been invited to join More"
                        self?.subTitleLabel.text =
                            """
                            That's fantastic! Invites from trusted members help keep the More community safe and inspiring.

                            You can claim your Invite now.
                            """
                    } else {
                        self?.titleLabel.text = "\(profile.firstName ?? "") invited you to join More."
                        self?.subTitleLabel.text =
                            """
                            That's fantastic! Invites from trusted members help keep the More community safe and inspiring.

                            You can claim \(profile.firstName ?? "")'s Invite now.
                            """
                    }
                }
                self?.titleLabel.isHidden = false
                self?.subTitleLabel.isHidden = false
            }
        }
    }
    
    @IBAction private func onAcceptClicked(_ sender: UIButton) {
        onAccept?()
    }
    
    @IBAction private func onRejectClicked(_ sender: UIButton) {
        onReject?()
    }
    
    
    
}
