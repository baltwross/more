//
//  ExperienceTierFullPopup.swift
//  More
//
//  Created by Luko Gjenero on 04/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ExperienceTierFullPopup: LoadableView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var joinButton: UIButton!
    
    var joinTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        layer.cornerRadius = 45
        layer.masksToBounds = true
        
        joinButton.layer.cornerRadius = 22.5
        joinButton.layer.masksToBounds = true
    }
    
    func setup(for post: ExperiencePost) {
        
        messageLabel.text =
        """
        Unfortunately, the last spot for this Time was just taken.

        Would you like to join the waitlist? We can notify you if a spot opens up, or when \(post.creator.name) goes live again.
        """
    }
    
    @IBAction private func joinTouch(_ sender: Any) {
        joinTap?()
    }

}
