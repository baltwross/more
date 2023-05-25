//
//  ExperienceCreatorView.swift
//  More
//
//  Created by Luko Gjenero on 21/02/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceCreatorView: LoadableView {

    @IBOutlet private weak var avatar: TimeAvatarView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var button: UIButton!

    var profileTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        avatar.progress = 0
        avatar.progressBackgroundColor = .clear
        avatar.outlineColor = UIColor(red: 191, green: 195, blue: 202).withAlphaComponent(0.75)
        avatar.ringSize = 1
        avatar.imagePadding = 3
        
        name.font = UIFont(name: "Gotham-MediumItalic", size: 14)
    }
    
    func setup(for user: ShortUser) {
        avatar.imageUrl = user.avatar
        name.text = user.name
    }
    
    @IBAction private func profileTouch(_ sender: Any) {
        profileTap?()
    }
}
