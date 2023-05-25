//
//  ChatViewLeftHeader.swift
//  More
//
//  Created by Luko Gjenero on 26/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ChatViewLeftHeader: LoadableView {

    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var name: UILabel!
    
    var backTap: (()->())?
    var profileTap: (()->())?
    
    func hideBack() {
        button.isHidden = true
        buttonWidth.constant = 8
    }
    
    func setup(for user: ShortUser) {
        avatar.sd_progressive_setImage(with: URL(string: user.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        name.text = user.name
    }
    
    @IBAction private func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction private func profileTouch(_ sender: Any) {
        profileTap?()
    }
    

}
