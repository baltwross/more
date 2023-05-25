//
//  ChatUserInfoCell.swift
//  More
//
//  Created by Luko Gjenero on 26/03/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ChatUserInfoCell: ChatBaseCell {

    @IBOutlet private weak var infoText: UILabel!
    @IBOutlet private weak var actionText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setup(for message: Message, in chat: Chat) {
        
        switch message.type {
        case .request:
            if message.sender.isMe() {
                infoText.text = "You requested to join the group"
                actionText.text = ""
            } else {
                infoText.text = "\(message.sender.name) requested to join the group"
                actionText.text = "View profile"
            }
        case .expired:
            infoText.text = "Time ended"
            actionText.text = ""
        case .met:
            infoText.text = "You have met."
            actionText.text = ""
        case .created:
            if message.sender.isMe() {
                infoText.text = "You created the group"
                actionText.text = ""
            } else {
                infoText.text = "\(message.sender.name) created the group"
                actionText.text = "View profile"
            }
        case .joined:
            if message.sender.isMe() {
                infoText.text = "You joined the group"
                actionText.text = ""
            } else {
                infoText.text = "\(message.sender.name) joined the group"
                actionText.text = "View profile"
            }
        case .startCall:
            if message.sender.isMe() {
                infoText.text = "You started the call"
                actionText.text = ""
            } else {
                infoText.text = "\(message.sender.name) started the call"
                actionText.text = "View profile"
            }
        default:
            infoText.text = ""
            actionText.text = ""
        }
    }
    
}
