//
//  GroupRequestTableViewCell.swift
//  More
//
//  Created by Luko Gjenero on 28/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class GroupRequestTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var smallAvatar: AvatarImage!
    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var timeAvatar: TimeAvatarView!
    @IBOutlet private weak var smallTimeAvatar: TimeAvatarView!
    @IBOutlet private weak var badge: UILabel!
    @IBOutlet private weak var descriptionView: RequestViewDescriptionView!
    @IBOutlet private weak var dot: UIView!
    @IBOutlet private weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        badge.layer.cornerRadius = 10
        badge.layer.masksToBounds = true
        badge.isHidden = true
        
        dot.layer.cornerRadius = 2.5
        dot.layer.masksToBounds = true
        dot.isHidden = true
    }
    
    func setup(for item: Chat) {
        let post = Chat.getPost(for: item)
        let request = Chat.getRequest(for: item)
        let time = Chat.getTime(for: item)
        setupAvatar(for: item, post: post, request: request, time: time)
        setupBadge(for: item)
        descriptionView.setup(for: item, post: post, request: request, time: time)
        setupTime(for: item, post: post, request: request, time: time)
    }
    
    // MARK: - UI
    
    private func setupBadge(for item: Chat) {
        let unread = item.messages?.filter { !$0.isMine() && !$0.haveRead() }.count ?? 0
        
        // dot
        dot.isHidden = unread <= 0
    }
    
    private func setupAvatar(for item: Chat, post: ExperiencePost?, request: ExperienceRequest?, time: ExperienceTime?) {
        if item.other().id == Id.More {
            if let latest = item.latestMessage(), !latest.isMine(), !latest.haveRead() == nil {
                avatar.isHidden = true
                smallAvatar.isHidden = true
                smallTimeAvatar.isHidden = true
                timeAvatar.isHidden = false
                timeAvatar.type = .magical
                timeAvatar.progress = 1
                timeAvatar.image = UIImage(named: "welcome")
            } else {
                avatar.isHidden = false
                timeAvatar.isHidden = true
                avatar.image = UIImage(named: "welcome")
            }
            return
        }
        
        // members who are not me
        let notMe = item.members.filter({ !$0.isMe()} )
        
        // active
        if let post = post, post.expiresAt.timeIntervalSinceNow > 0 {
            avatar.isHidden = true
            smallAvatar.isHidden = true
            
            // main avatar
            if let first = notMe.first {
                timeAvatar.isHidden = false
                timeAvatar.type = post.experience.type
                timeAvatar.progress = 1
                timeAvatar.imageUrl = first.avatar
            } else {
                timeAvatar.isHidden = true
            }
            
            // secondary
            if notMe.count > 1 {
                let second = notMe[1]
                smallTimeAvatar.isHidden = false
                smallTimeAvatar.type = post.experience.type
                smallTimeAvatar.progress = 1
                smallTimeAvatar.imageUrl = second.avatar
            } else {
                smallTimeAvatar.isHidden = true
            }
            
            return
        }
        
        // passive
        timeAvatar.isHidden = true
        smallTimeAvatar.isHidden = true
        
        // main avatar
        if let first = notMe.first, let url = URL(string: first.avatar) {
            avatar.isHidden = false
            avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder())
        } else {
            avatar.isHidden = true
            avatar.sd_cancelCurrentImageLoad_progressive()
        }
        // main avatar
        if notMe.count > 1 {
            let second = notMe[1]
            smallAvatar.isHidden = false
            if let url = URL(string: second.avatar) {
                smallAvatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder())
            }
        } else {
            smallAvatar.isHidden = true
            smallAvatar.sd_cancelCurrentImageLoad_progressive()
        }
    }
    
    private func setupTime(for item: Chat, post: ExperiencePost?, request: ExperienceRequest?, time: ExperienceTime?) {
        self.time.isHidden = false
        if item.other().id == Id.More {
            self.time.isHidden = true
            return
        }
        
        if let latest = item.latestMessage() {
            self.time.text = latest.createdAt.requestDateFormatted
            return
        }
    }
    
}

// MARK: - date format

private let minInSecs: TimeInterval = 60
private let hourInSecs: TimeInterval = 3600
private let dayInSecs: TimeInterval = 86400
private let weekInSecs: TimeInterval = 604800

private extension Date {
    var requestDateFormatted: String {
        let timeInSeconds = -timeIntervalSinceNow
        if timeInSeconds > weekInSecs {
            let weeks = Int(timeInSeconds / weekInSecs)
            return "\(weeks)w"
        } else if timeInSeconds > dayInSecs {
            let days = Int(timeInSeconds / dayInSecs)
            return "\(days)d"
        } else if timeInSeconds > hourInSecs {
            let hours = Int(timeInSeconds / hourInSecs)
            return "\(hours)h"
        }
        let mins = Int(min(1,timeInSeconds / minInSecs))
        return "\(mins)m"
    }
}
