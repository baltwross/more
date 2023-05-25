//
//  ChatBaseCell.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ChatBaseCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setup(for message: Message, in chat: Chat) { }

}
