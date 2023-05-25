//
//  ChatReviewTopBar.swift
//  More
//
//  Created by Luko Gjenero on 29/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ChatReviewTopBar: LoadableView {

    @IBOutlet weak var myAvatar: AvatarImage!
    @IBOutlet weak var otherAvatar: AvatarImage!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var buttonTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        button.layer.cornerRadius = 18
        button.layer.borderColor = UIColor(red: 221, green: 231, blue: 255).cgColor
        button.layer.borderWidth = 1.5
    }
    
    func setup(for time: Time) {
        setupAvatars(for: time)
        setupLabel(for: time)
    }
    
    private func setupAvatars(for time: Time) {
        myAvatar.sd_progressive_setImage(with: URL(string: ProfileService.shared.profile?.images?.first?.url ?? ""), placeholderImage: UIImage.profileThumbPlaceholder())
        otherAvatar.sd_progressive_setImage(with: URL(string: time.otherPerson().avatar), placeholderImage: UIImage.profileThumbPlaceholder())
    }
    
    private func setupLabel(for time: Time) {
        
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Avenir-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13)
        var part = NSAttributedString(
            string: "Time with ",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 124, green: 139, blue: 155),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Heavy", size: 13) ?? UIFont.systemFont(ofSize: 13)
        part = NSAttributedString(
            string: time.otherPerson().name,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 67, green: 74, blue: 81),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        label.attributedText = text
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        buttonTap?()
    }
}
