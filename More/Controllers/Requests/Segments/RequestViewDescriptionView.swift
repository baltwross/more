//
//  RequestViewDescriptionView.swift
//  More
//
//  Created by Luko Gjenero on 24/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class RequestViewDescriptionView: LoadableView {

    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var message: UILabel!
    @IBOutlet private weak var info: UILabel!
    
    func setup(for item: Chat, post: ExperiencePost?, request: ExperienceRequest?, time: ExperienceTime?) {
        setupName(for: item)
        setupMessage(for: item, post: post, request: request, time: time)
        setupInfo(for: item, post: post, request: request, time: time)
    }
    
    private func setupName(for item: Chat) {
        if item.other().id == Id.More {
            name.text = "More team"
            return
        }
        
        if item.members.count > 3 {
            name.text = "\(item.other().name) & \(item.members.count - 2) others"
        } else if item.members.count > 2 {
            name.text = "\(item.other().name) & 1 other"
        } else {
            name.text = item.other().name
        }
    }
    
    private func setupMessage(for item: Chat, post: ExperiencePost?, request: ExperienceRequest?, time: ExperienceTime?) {
        message.font = UIFont(name: "Avenir-Medium", size: 13)
        if let latest = item.latestMessage() {
            if !latest.isMine() && !latest.haveRead() == nil {
                message.font = UIFont(name: "Avenir-Heavy", size: 13)
            }
            if latest.type == .welcome {
                 message.text = "Say Hello to the Times of your life!"
            } else {
                message.text = latest.text
            }
            return
        }
        
        message.text = ""
    }
    
    private func setupInfo(for item: Chat, post: ExperiencePost?, request: ExperienceRequest?, time: ExperienceTime?) {
        
        if item.other().id == Id.More {
            info.textColor = SignalType.magical.color
            info.text = "Video"
            return
        }
        
        if let post = post, let request = request,
            post.chat == nil || post.chat?.id == item.id,
            request.accepted == nil, post.expiresAt.timeIntervalSinceNow > 0 {
            info.textColor = post.experience.type.color
            info.text = "Active"
            return
        }
        
        if let time = time {
            if false { //  !time.haveReviewed() {
                info.textColor = UIColor.carolinaBlue
                info.text = "Needs Review"
            } else {
                info.textColor = UIColor(red: 147, green: 158, blue: 174)
                info.text = "You met"
            }
            return
        }
        
        info.textColor = UIColor(red: 147, green: 158, blue: 174)
        if let latest = item.latestMessage(of: [.request, .expired, .accepted, .met, .review]) {
            switch latest.type {
            case .expired:
                info.text = "Expired"
            default:
                 info.text = "You Met"
            }
            return
        }
        info.text = ""
    }

}
