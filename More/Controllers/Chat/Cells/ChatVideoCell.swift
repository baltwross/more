//
//  ChatVideoCell.swift
//  More
//
//  Created by Luko Gjenero on 10/01/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ChatVideoCell: ChatBaseCell {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var video: MoreVideoView!
    @IBOutlet private weak var startStopButton: UIButton!
    @IBOutlet private weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        video.layer.masksToBounds = true
        video.layer.cornerRadius = 12
        
        startStopButton.isSelected = false
        startStopButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        startStopButton.alpha = 1
        startStopButton.layer.masksToBounds = true
        startStopButton.layer.cornerRadius = 12
    }

    override func setup(for message: Message, in chat: Chat) {
        
        if message.type == .welcome  {
            avatar.image = UIImage(named: "welcome")
        } else {
            let user = chat.members.first { $0.id == message.sender.id } ?? message.sender
            avatar.sd_progressive_setImage(with: URL(string: user.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        }
        
        let urlStr: String = (message.type == .welcome ? Urls.welcomeVideo : nil) ?? message.text
        if let url = URL(string: urlStr) {
            video.setup(for: url)
        }
        
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        time.text = df.string(from: message.createdAt)
        
        startStopButton.isSelected = false
        startStopButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        startStopButton.alpha = 1
    }
    
    @IBAction private func startStopTouch(_ sender: Any) {
        if startStopButton.isSelected {
            video.stop()
            startStopButton.isSelected = false
            startStopButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            startStopButton.alpha = 1
        } else {
            video.play()
            startStopButton.isSelected = true
            startStopButton.backgroundColor = .clear
            startStopButton.alpha = 0.5
        }
    }
    
}
