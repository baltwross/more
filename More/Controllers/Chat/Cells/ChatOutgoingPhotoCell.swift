//
//  ChatOutgoingPhotoCell.swift
//  More
//
//  Created by Luko Gjenero on 24/03/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ChatOutgoingPhotoCell: ChatBaseCell {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var photo: UIImageView!
    @IBOutlet private weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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

        let avatarUrl = ProfileService.shared.profile?.images?.first?.url ?? message.sender.avatar
        if let url = URL(string: avatarUrl) {
            avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder())
        } else {
            avatar.sd_cancelCurrentImageLoad_progressive()
        }
        
        photo?.sd_progressive_setImage(with: URL(string: message.additionalUrl() ?? ""), placeholderImage: UIImage.expandedSignalPlaceholder())
        
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
