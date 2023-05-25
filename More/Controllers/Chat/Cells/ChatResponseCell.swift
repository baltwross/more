//
//  ChatResponseCell.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ChatResponseCell: UITableViewCell {

    @IBOutlet private weak var responseText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setup(for message: Message, in chat: Chat) {
        setupText(for: message, in: chat)
    }
    
    private func setupText(for message: Message, in chat: Chat) {
        if message.sender.isMe() {
            if message.type == .accepted {
                responseText.text = "You accepted \(chat.other().name)'s request."
            } else {
                responseText.text = "This request has expired."
            }
        } else {
            if message.type == .accepted {
                responseText.text = "\(chat.other().name) accepted your request."
            } else {
                responseText.text = "This request has expired."
            }
        }
    }
}
