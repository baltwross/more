//
//  MessagingViewBaseCell.swift
//  More
//
//  Created by Luko Gjenero on 24/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class MessagingViewBaseCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    class func size(for model: MessageViewModel, in size: CGSize) -> CGSize {
        return .zero
    }
    
    class func isShowing(for model: MessageViewModel) -> Bool {
        return false
    }
    
    func setup(for model: MessageViewModel) { }
    
    var isEditable: Bool = false

    var editTap: (()->())?

    var timeFormat: String = "h:mm a"
}

