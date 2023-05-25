//
//  SignalDetailsLikesCell.swift
//  More
//
//  Created by Luko Gjenero on 24/02/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class SignalDetailsLikesCell: SignalDetailsBaseCell {
    
    @IBOutlet private weak var avatars: AvatarStackView!
    @IBOutlet private weak var label: UILabel!

    // MARK: - experience details view
    
    override class func isShowing(for experience: Experience) -> Bool {
        return (experience.numOfLikes ?? 0)  >= ConfigService.shared.likesThreshold
    }
    
    override func setup(for experience: Experience) {
        avatars.isHidden = true
        label.isHidden = true
        loadLikes(for: experience)
    }
    
    // MARK: - experience preview
    
    override func setup(for model: CreateExperienceViewModel) {
        // nothing
    }
    
    override class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        return false
    }
    
    // MARK: load likes
    
    private func loadLikes(for experience: Experience) {
        guard let count = experience.numOfLikes, count > 0 else { return }
        ExperienceService.shared.loadExperienceLikes(experienceId: experience.id, limit: 2) { [weak self] (likes, _, _) in
            if let likes = likes {
                self?.setup(experience: experience, likes: likes)
            }
        }
    }
    
    private func setup(experience: Experience, likes: [ExperienceLike]) {
        var urls: [String] = []
        var name: String = ""
        
        if likes.count >= 1 {
            if likes.count >= 2 {
                urls = [likes[1].creator.avatar, likes[0].creator.avatar]
            } else {
                urls = [likes[0].creator.avatar]
            }
            name = likes[0].creator.name
        }
        
        avatars.isHidden = false
        label.isHidden = false
        avatars.setup(for: urls)
        setupLabel(name: name, count: experience.numOfLikes ?? 0)
    }
    
    private func setupLabel(name: String, count: Int) {
        let text = NSMutableAttributedString()
                
        let font = UIFont(name: "Gotham-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13)
        var part = NSAttributedString(
            string: "Liked by ",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.blueGrey,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        part = NSAttributedString(
            string: name,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGrey,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        if count > 1 {
            part = NSAttributedString(
                string: " and ",
                attributes: [NSAttributedString.Key.foregroundColor : UIColor.blueGrey,
                             NSAttributedString.Key.font : font])
            text.append(part)
            
            let suffix = count > 2 ? "others" : "other"
            part = NSAttributedString(
                string: "\(count-1) \(suffix)",
                attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGrey,
                             NSAttributedString.Key.font : font])
            text.append(part)
        }
         
         label.attributedText = text
    }
    
}
