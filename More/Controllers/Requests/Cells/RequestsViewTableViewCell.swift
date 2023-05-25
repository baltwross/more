//
//  RequestsViewTableViewCell.swift
//  More
//
//  Created by Luko Gjenero on 24/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class RequestsViewTableViewCell: UITableViewCell {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var timeAvatar: TimeAvatarView!
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
        
        /*
        // badge
        if unread > 0 {
            badge.isHidden = false
            if unread > 9 {
                badge.text = "9+"
            } else {
                badge.text = "\(unread)"
            }
        } else {
            badge.isHidden = true
        }
        */
        
        // dot
        dot.isHidden = unread <= 0
    }
    
    private func setupAvatar(for item: Chat, post: ExperiencePost?, request: ExperienceRequest?, time: ExperienceTime?) {
        if item.other().id == Id.More {
            if let latest = item.latestMessage(), !latest.isMine(), !latest.haveRead() {
                avatar.isHidden = true
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
        
        if let post = post, let request = request,
            post.chat == nil || post.chat?.id == item.id,
            request.accepted == nil, post.expiresAt.timeIntervalSinceNow > 0 {
            avatar.isHidden = true
            timeAvatar.isHidden = false
            timeAvatar.type = post.experience.type
            timeAvatar.setupRunningProgress(start: request.createdAt, end: post.expiresAt)
            timeAvatar.imageUrl = item.other().avatar
            return
        }
        
        avatar.isHidden = false
        timeAvatar.isHidden = true
        if let url = URL(string: item.other().avatar) {
            avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder())
        } else {
            avatar.sd_cancelCurrentImageLoad_progressive()
        }
    }
    
    private func setupTime(for item: Chat, post: ExperiencePost?, request: ExperienceRequest?, time: ExperienceTime?) {
        self.time.isHidden = true
        if item.other().id == Id.More {
            return
        }
        
        if let latest = item.latestMessage() {
            self.time.isHidden = false
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
