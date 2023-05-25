//
//  MessagingViewOutgoingCell.swift
//  More
//
//  Created by Luko Gjenero on 24/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class MessagingViewOutgoingCell: MessagingViewBaseCell {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var message: UILabel!
    @IBOutlet private weak var time: UILabel!
    @IBOutlet private weak var editButton: UIButton!
    
    @IBAction private func editTouch(_ sender: Any) {
        editTap?()
    }
    
    // MARK: - base
    
    override class func size(for model: MessageViewModel, in size: CGSize) -> CGSize {
        
        let textFont = UIFont(name: "Avenir-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15)
        let timeFont = UIFont(name: "Avenir-Heavy", size: 10) ?? UIFont.systemFont(ofSize: 10)
        
        let msgHeight = max(22, model.text.height(withConstrainedWidth: size.width - 152, font: textFont))
        let timeHeight = "999".height(withConstrainedWidth: size.width - 152, font: timeFont)
        let height = 40 + msgHeight + timeHeight
        
        return CGSize(width: size.width, height: height)
    }
    
    
    override class func isShowing(for model: MessageViewModel) -> Bool {
        return true
    }
    
    override func setup(for model: MessageViewModel) {
        
        avatar.sd_progressive_setImage(with: URL(string: model.sender.avatarUrl), placeholderImage: UIImage.profileThumbPlaceholder())
        message.text = model.text
        
        if timeFormat == "h:mm a" {
            let df = DateFormatter()
            df.dateFormat = "h:mm a"
            if let read = model.read {
                time.text = "Read \(df.string(from: read))"
            } else if let delivered = model.delivered {
                time.text = "Delivered \(df.string(from: delivered))"
            } else {
                time.text = "Sent \(df.string(from: model.createdAt))"
            }
        } else {
            time.text = timeFormat
        }
    }
    
    override var isEditable: Bool {
        get {
            return !editButton.isHidden
        }
        set {
            editButton.isHidden = !newValue
        }
    }
    
}
