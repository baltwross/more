//
//  AvatarStackView.swift
//  More
//
//  Created by Luko Gjenero on 09/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
class AvatarStackView: LoadableView {

    @IBOutlet private weak var avatar1: UIImageView!
    @IBOutlet private weak var avatar2: UIImageView!
    @IBOutlet private weak var avatar3: UIImageView!
    
    @IBOutlet private var right1: NSLayoutConstraint!
    @IBOutlet private var right2: NSLayoutConstraint!
    @IBOutlet private var right3: NSLayoutConstraint!
    
    override func setupNib() {
        super.setupNib()
        
        right1.isActive = true
        right2.isActive = false
        right3.isActive = false
        
        avatar1.isHidden = true
        avatar2.isHidden = true
        avatar3.isHidden = true
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        right1.isActive = false
        right2.isActive = false
        right3.isActive = true
        avatar1.isHidden = false
        avatar2.isHidden = false
        avatar3.isHidden = false
    }
    
    private var avatars: [UIImageView] {
        return [avatar1, avatar2, avatar3]
    }
    
    func setup(for urls: [String]) {
        
        // layout
        switch urls.count {
        case 2:
            right1.isActive = false
            right2.isActive = true
            right3.isActive = false
        case 3...:
            right1.isActive = false
            right2.isActive = false
            right3.isActive = true
        default:
            right1.isActive = true
            right2.isActive = false
            right3.isActive = false
        }
        
        // TODO: - setup images
        for (idx, avatar) in avatars.enumerated() {
            if idx < urls.count {
                let reverseIdx = urls.count - idx - 1
                if let url = URL(string: urls[reverseIdx]) {
                    avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder())
                } else {
                    avatar.sd_cancelCurrentImageLoad_progressive()
                    avatar.image = UIImage.profileThumbPlaceholder()
                }
                avatar.isHidden = false
            } else {
                avatar.sd_cancelCurrentImageLoad_progressive()
                avatar.isHidden = true
            }
        }
    }
    
    func setupForEmpty() {
        right1.isActive = true
        right2.isActive = false
        right3.isActive = false
        avatar1.isHidden = false
        avatar2.isHidden = true
        avatar3.isHidden = true
        
        avatar1.sd_cancelCurrentImageLoad_progressive()
        avatar1.image = nil
    }
    
    func setupForMore() {
        right1.isActive = true
        right2.isActive = false
        right3.isActive = false
        avatar1.isHidden = false
        avatar2.isHidden = true
        avatar3.isHidden = true
        
        avatar1.sd_cancelCurrentImageLoad_progressive()
        avatar1.image = UIImage(named: "more-icon")
    }
    
    
}
