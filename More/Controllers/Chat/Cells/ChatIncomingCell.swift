//
//  ChatIncomingCell.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ChatIncomingCell: ChatBaseCell {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var message: UILabel!
    @IBOutlet private weak var time: UILabel!

    override func setup(for message: Message, in chat: Chat) {

        let user = chat.members.first { $0.id == message.sender.id } ?? message.sender
        
        avatar.sd_progressive_setImage(with: URL(string: user.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        self.message.text = message.text
        
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        time.text = df.string(from: message.createdAt)
    }
}
