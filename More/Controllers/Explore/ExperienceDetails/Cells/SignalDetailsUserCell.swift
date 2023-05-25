//
//  SignalDetailsUserCell.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

class SignalDetailsUserCell: SignalDetailsBaseCell {
    
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var followButton: UIButton!
    
    var viewProfile: (()->())?
    var follow: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.borderColor = UIColor.lightPeriwinkle.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 18
        followButton.layer.masksToBounds = true
    }
    
    @IBAction private func viewProfileTouch(_ sender: Any) {
        viewProfile?()
    }
    
    @IBAction private func followTouch(_ sender: Any) {
        follow?()
    }
    
    // MARK: - experience details view
    
    override class func isShowing(for experience: Experience) -> Bool {
        return true
    }
    
    override func setup(for experience: Experience) {
//        if let post = experience.posts?.first {
//            if let url = URL(string: post.creator.avatar) {
//                avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder(), options: .highPriority)
//            } else {
//                avatar.sd_cancelCurrentImageLoad_progressive()
//                avatar.image = nil
//            }
//            name.text = post.creator.name
//            return
//        }
        
        if let url = URL(string: experience.creator.avatar) {
            avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder(), options: .highPriority)
        } else {
            avatar.sd_cancelCurrentImageLoad_progressive()
            avatar.image = nil
        }
        name.text = experience.creator.name
    }
    
}
