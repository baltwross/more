//
//  ChatViewVideoUserTag.swift
//  More
//
//  Created by Luko Gjenero on 21/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ChatViewVideoUserTag: LoadableView {

    @IBOutlet private weak var avatar: TimeAvatarView!
    @IBOutlet private weak var name: UILabel!
    
    var tap: (()->())?
    
    private (set) var user: ShortUser?
    
    override func setupNib() {
        super.setupNib()
        
        avatar.progress = 0
        avatar.progressBackgroundColor = .clear
        avatar.outlineColor = UIColor(red: 191, green: 195, blue: 202).withAlphaComponent(0.75)
        avatar.ringSize = 1
        avatar.imagePadding = 3
    }
    
    func setup(for user: ShortUser) {
        self.user = user
        name.text = user.name
        avatar.imageUrl = user.avatar
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        tap?()
    }

}
