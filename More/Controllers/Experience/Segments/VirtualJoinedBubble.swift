//
//  VirtualJoinedBubble.swift
//  More
//
//  Created by Luko Gjenero on 05/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class VirtualJoinedBubble: LoadableView {

    @IBOutlet private weak var blur: UIVisualEffectView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var enterButton: UIButton!
    
    var enterTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        blur.layer.cornerRadius = 45
        blur.layer.masksToBounds = true
        
        enterButton.layer.cornerRadius = 22.5
        enterButton.layer.masksToBounds = true
    }
    
    func setup(for experience: Experience) {
        
        if experience.tier == nil {
            titleLabel.text = "You successfully joined the time"
        } else {
            titleLabel.text = "Your Payment Was Successful"
        }
        
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        var part = NSAttributedString(
            string: "You’ve successfully joined the Time “",
            attributes: [.font: font, .foregroundColor: UIColor.blueGrey])
        text.append(part)
        
        font = UIFont(name: "Gotham-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16)
        part = NSAttributedString(
            string: "\(experience.title)",
            attributes: [.font: font, .foregroundColor: UIColor.charcoalGrey])
        text.append(part)
        
        font = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        part = NSAttributedString(
            string: "” and can now enter the room.",
            attributes: [.font: font, .foregroundColor: UIColor.blueGrey])
        text.append(part)
        
        messageLabel.attributedText = text
    }
    
    @IBAction private func enterTouch(_ sender: Any) {
        enterTap?()
    }


}
