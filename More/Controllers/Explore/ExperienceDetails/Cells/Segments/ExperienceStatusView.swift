//
//  ExperienceStatusView.swift
//  More
//
//  Created by Luko Gjenero on 27/02/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceStatusView: LoadableView {

    @IBOutlet private weak var avatar: TimeAvatarView!
    @IBOutlet private weak var avatarButton: UIButton!
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var likeLabel: UILabel!
    @IBOutlet private weak var likeHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var shareLabel: UILabel!
    @IBOutlet private weak var shareHeight: NSLayoutConstraint!
    
    var like: (()->())?
    var share: (()->())?
    var creator: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        avatar.progress = 0
        avatar.progressBackgroundColor = .clear
        avatar.outlineColor = UIColor(red: 191, green: 195, blue: 202).withAlphaComponent(0.75)
        avatar.ringSize = 1
        avatar.imagePadding = 3
        
        // shadows ??
    }
    
    func setup(for experience: Experience) {
        avatar.imageUrl = experience.creator.avatar
        
        if (experience.numOfLikes ?? 0) >= ConfigService.shared.likesThreshold {
            likeLabel.text = Formatting.formatLikesAndShares(experience.numOfLikes ?? 0, asShortWithDecimals: 1, threshold: 999)
            likeLabel.isHidden = false
            likeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
            likeHeight.constant = 48
            ExperienceService.shared.haveLikedExperience(experienceId: experience.id) { [weak self] (liked, _) in
                if let liked = liked {
                    self?.likeButton.tintColor = liked ? .fireEngineRed : .whiteThree
                } else {
                    self?.likeButton.tintColor = .whiteThree
                }
            }
        } else {
            likeButton.tintColor = .whiteThree
            likeLabel.isHidden = true
            likeButton.imageEdgeInsets = .zero
            likeHeight.constant = 30
        }
        
        if (experience.numOfShares ?? 0) >= ConfigService.shared.sharesThreshold {
            shareLabel.text = Formatting.formatLikesAndShares(experience.numOfShares ?? 0, asShortWithDecimals: 1, threshold: 999)
            shareLabel.isHidden = false
            shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 18, right: 0)
            shareHeight.constant = 48
        } else {
            shareLabel.isHidden = true
            shareButton.imageEdgeInsets = .zero
            shareHeight.constant = 30
        }
    }
    
    @IBAction private func avatarTouch(_ sender: Any) {
        creator?()
    }
    
    @IBAction private func shareTouch(_ sender: Any) {
        share?()
    }
    
    @IBAction private func likeTouch(_ sender: Any) {
        like?()
    }
}
