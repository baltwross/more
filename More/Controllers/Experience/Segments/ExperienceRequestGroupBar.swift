//
//  ExperienceRequestGroupBar.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceRequestGroupBar: LoadableView {

    @IBOutlet private weak var avatarStack: AvatarStackView!
    @IBOutlet private weak var additional: UILabel!
    @IBOutlet private weak var additionalWidth: NSLayoutConstraint!
    @IBOutlet private weak var names: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var buttonTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        additional.layer.masksToBounds = true
        additional.layer.cornerRadius = 17.5
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        buttonTap?()
    }
    
    func setup(for post: ExperiencePost) {
        var users: [ShortUser] = []
        users.append(post.creator.short())
        
        for request in post.requests ?? [] {
            if request.accepted == true {
                users.append(request.creator)
            }
        }
        
        avatarStack.setup(for: users.map { $0.avatar })
        
        if users.count > 3 {
            additionalWidth.constant = 35
            additional.isHidden = false
            additional.text = "\(users.count - 3)+"
        } else {
            additionalWidth.constant = 4
            additional.isHidden = true
        }
        
        var text = "\(users.first?.name ?? "")"
        if users.count > 2 {
            text += " & \(users.count - 1) others"
        } else if users.count > 1 {
            text += " & 1 other"
        }
        names.text = text
    }
    
    func setupForConfirm() {
        button.setTitle("CONFIRM", for: .normal)
    }
    
    func setupForRequest() {
        button.setTitle("JOIN", for: .normal)
    }
}
