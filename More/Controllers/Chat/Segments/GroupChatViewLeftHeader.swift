//
//  GroupChatViewLeftHeader.swift
//  More
//
//  Created by Luko Gjenero on 03/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class GroupChatViewLeftHeader: LoadableView {

    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet private weak var avatarStack: AvatarStackView!
    @IBOutlet private weak var additional: UILabel!
    @IBOutlet private weak var additionalWidth: NSLayoutConstraint!
    @IBOutlet private weak var names: UILabel!
    @IBOutlet private weak var groupButton: UIButton!

    var backTap: (()->())?
    var groupTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        additional.layer.masksToBounds = true
        additional.layer.cornerRadius = 17.5
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction private func groupTouch(_ sender: Any) {
        groupTap?()
    }
    
    func hideBack() {
        button.isHidden = true
        buttonWidth.constant = 8
    }
    
    func setup(for post: ExperiencePost) {
        var users: [ShortUser] = []
        users.append(post.creator.short())
        
        for request in post.requests ?? [] {
            if request.accepted == true {
                users.append(request.creator)
            }
        }
        setup(for: users)
    }
    
    func setup(for chat: Chat) {
        setup(for: chat.members)
    }
    
    private func setup(for users: [ShortUser]) {
        
        avatarStack.setup(for: users.map { $0.avatar })
        
        if users.count > 3 {
            additionalWidth.constant = 35
            additional.isHidden = false
            additional.text = "\(users.count - 3)+"
        } else {
            additionalWidth.constant = 4
            additional.isHidden = true
        }
        
        var text = ""
        for (idx, user) in users.enumerated() {
            if idx >= 4 {
                if users.count == idx + 1 {
                    text += " & "
                } else {
                    text += ", "
                }
            } else if idx > 0 {
                text += ", "
            }
            text += user.name
            
            if idx >= 4 {
                break
            }
        }
        if users.count > 5 {
            text += " & \(users.count - 5) others"
        }
        names.text = text
    }
    
}
