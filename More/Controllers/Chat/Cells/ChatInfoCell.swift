//
//  ChatInfoCell.swift
//  More
//
//  Created by Luko Gjenero on 26/03/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ChatInfoCell: ChatBaseCell {

    @IBOutlet private weak var infoText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setup(for message: Message, in chat: Chat) {
        
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Avenir-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        var part = NSAttributedString(
            string: "New group created for:\n",
            attributes: [.foregroundColor : UIColor.blueGrey, .font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Heavy", size: 12) ?? UIFont.systemFont(ofSize: 12)
        part = NSAttributedString(
            string: "\(message.additionalVirtualTimeTitle() ?? "")\n",
            attributes: [.foregroundColor : UIColor.blueGrey, .font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Heavy", size: 12) ?? UIFont.systemFont(ofSize: 12)
        part = NSAttributedString(
            string: "View Time",
            attributes: [.foregroundColor : UIColor.cornflower, .font : font])
        text.append(part)
        
        infoText.attributedText = text
    }
    
}
