//
//  ChatIncomingVideoCell.swift
//  More
//
//  Created by Luko Gjenero on 24/03/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage
import QuickLook

class ChatIncomingVideoCell: ChatBaseCell {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var photo: UIImageView!
    @IBOutlet private weak var button: UIView!
    @IBOutlet private weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.layer.cornerRadius = 17.5
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        photo.layer.cornerRadius = 15
        photo.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.enableShadow(color: .black, path: UIBezierPath(roundedRect: photo.frame, cornerRadius: 15).cgPath)
    }
    
    override func setup(for message: Message, in chat: Chat) {

        let user = chat.members.first { $0.id == message.sender.id } ?? message.sender
        
        avatar.sd_progressive_setImage(with: URL(string: user.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        
        photo?.sd_progressive_setImage(with: URL(string: message.additionalPreviewUrl() ?? ""), placeholderImage: UIImage.expandedSignalPlaceholder())
        
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        time.text = df.string(from: message.createdAt)
    }
}
