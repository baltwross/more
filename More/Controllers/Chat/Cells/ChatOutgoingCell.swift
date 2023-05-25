//
//  ChatOutgoingCell.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ChatOutgoingCell: ChatBaseCell {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var message: UILabel!
    @IBOutlet private weak var time: UILabel!
    
    override func setup(for message: Message, in chat: Chat) {
        
        let avatarUrl = ProfileService.shared.profile?.images?.first?.url ?? message.sender.avatar
        if let url = URL(string: avatarUrl) {
            avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder())
        } else {
            avatar.sd_cancelCurrentImageLoad_progressive()
        }
        self.message.text = message.text
        
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        if let read = message.readAt?.values.sorted().first {
            time.text = "Read \(df.string(from: read))"
        } else if let delivered = message.deliveredAt?.values.sorted().first {
            time.text = "Delivered \(df.string(from: delivered))"
        } else {
            time.text = "Sent \(df.string(from: message.createdAt))"
        }
    }
    
}
