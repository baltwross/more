//
//  AlertContentView.swift
//  More
//
//  Created by Luko Gjenero on 18/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class AlertContentView: LoadableView {

    @IBOutlet private weak var smallAvatar: AvatarImage!
    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var timeAvatar: TimeAvatarView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet private weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet private weak var rate: StarsView!
    
    override func setupNib() {
        super.setupNib()
        
        let buttonColor = UIColor(red: 149, green: 182, blue: 255)
        button.setTitleColor(buttonColor, for: .normal)
        button.layer.borderColor = buttonColor.cgColor
    }
    
    func setupForRequest(_ request: Request, in signal: Signal) {
        
        smallAvatar.isHidden = true
        avatar.isHidden = true
        timeAvatar.isHidden = false
        button.isHidden = true
        buttonWidth.constant = 0
        rate.isHidden = true
        
        if request.sender.isMe() {
            setLabelText(normal: "You requested: ", bold: signal.text)
        } else {
            setLabelText(normal: "\(request.sender.name) requests: ", bold: signal.text)
        }
        timeAvatar.type = signal.type
        timeAvatar.setupRunningProgress(start: request.createdAt, end: request.expiresAt)
        timeAvatar.imageUrl = request.sender.avatar
    }
    
    func setupForMessgae(_ message: Message, in signal: Signal) {
        
        smallAvatar.isHidden = true
        avatar.isHidden = true
        timeAvatar.isHidden = false
        button.isHidden = true
        buttonWidth.constant = 0
        rate.isHidden = true
        
        setLabelText(normal: "\(message.sender.name) sent a message: ", bold: message.text)
        timeAvatar.type = signal.type
        if signal.isMine(), let request = signal.request(for: message.sender.id) {
            timeAvatar.setupRunningProgress(start: request.createdAt, end: request.expiresAt)
        } else if let request = signal.myRequest() {
            timeAvatar.setupRunningProgress(start: request.createdAt, end: request.expiresAt)
        } else {
            timeAvatar.setupRunningProgress(start: signal.createdAt, end: signal.expiresAt)
        }
        timeAvatar.imageUrl = message.sender.avatar
    }
    
    func setupForMessgae(_ message: Message, in post: ExperiencePost) {
        
        smallAvatar.isHidden = true
        avatar.isHidden = true
        timeAvatar.isHidden = false
        button.isHidden = true
        buttonWidth.constant = 0
        rate.isHidden = true
        
        switch message.type {
        case .photo:
            setLabelText(normal: "\(message.sender.name) sent a photo", bold: "")
        case .video:
            setLabelText(normal: "\(message.sender.name) sent a video", bold: "")
        case .startCall:
            setLabelText(normal: "\(message.sender.name) started a call", bold: "")
        case .joined:
            setLabelText(normal: "\(message.sender.name) joined the group", bold: "")
        case .created:
            setLabelText(normal: "\(message.sender.name) created the group", bold: "")
        default:
            setLabelText(normal: "\(message.sender.name) sent a message: ", bold: message.text)
        }
        timeAvatar.type = post.experience.type
        if post.creator.isMe(), let request = post.request(from: message.sender.id) {
            timeAvatar.setupRunningProgress(start: request.createdAt, end: post.expiresAt)
        } else if let request = post.myRequest() {
            timeAvatar.setupRunningProgress(start: request.createdAt, end: post.expiresAt)
        } else {
            timeAvatar.setupRunningProgress(start: post.createdAt, end: post.expiresAt)
        }
        timeAvatar.imageUrl = message.sender.avatar
    }
    
    func setupForMessgae(_ message: Message) {
        
        smallAvatar.isHidden = true
        avatar.isHidden = false
        timeAvatar.isHidden = true
        button.isHidden = true
        buttonWidth.constant = 0
        rate.isHidden = true
        
        switch message.type {
        case .photo:
            setLabelText(normal: "\(message.sender.name) sent a photo", bold: "")
        case .video:
            setLabelText(normal: "\(message.sender.name) sent a video", bold: "")
        case .startCall:
            setLabelText(normal: "\(message.sender.name) started a call", bold: "")
        case .joined:
            setLabelText(normal: "\(message.sender.name) joined the group", bold: "")
        case .created:
            setLabelText(normal: "\(message.sender.name) created the group", bold: "")
        default:
            setLabelText(normal: "\(message.sender.name) sent a message: ", bold: message.text)
        }
        avatar.sd_progressive_setImage(with: URL(string: message.sender.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
    }
    
    func setupForMessgae(_ message: Message, in time: Time) {
        
        smallAvatar.isHidden = true
        avatar.isHidden = false
        timeAvatar.isHidden = true
        button.isHidden = false
        buttonWidth.constant = 60
        rate.isHidden = true
        
        setLabelText(normal: "\(message.sender.name) sent a message: ", bold: message.text)
        avatar.sd_progressive_setImage(with: URL(string: message.sender.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        button.setTitle(nil, for: .normal)
        button.setImage(UIImage(named: "message_bubble_gray"), for: .normal)
        button.layer.cornerRadius = 0
        button.layer.borderWidth = 0
    }
    
    func setupForReview(in time: Time) {
        
        smallAvatar.isHidden = false
        avatar.isHidden = false
        timeAvatar.isHidden = true
        buttonWidth.constant = 100
        button.isHidden = false
        rate.isHidden = true
        
        if time.otherHasReviewed() && !time.haveReviewed() {
            setLabelText(normal: "\(time.otherPerson().name) wrote you a review.", bold: "")
        } else {
            setLabelText(normal: "You spent Time with \(time.otherPerson().name)", bold: "")
        }
        smallAvatar.sd_progressive_setImage(with: URL(string: ProfileService.shared.profile?.images?.first?.url ?? ""), placeholderImage: UIImage.profileThumbPlaceholder())
        avatar.sd_progressive_setImage(with: URL(string: time.otherPerson().avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        button.setImage(nil, for: .normal)
        button.setTitle("Write Review", for: .normal)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        
        if let myReview = time.myReview() {
            rate.rate = CGFloat(myReview.timeRate ?? 0)
        }
        
        if time.haveReviewed() {
            button.isHidden = true
            rate.isHidden = false
        } else {
            button.isHidden = false
            rate.isHidden = true
        }
    }
    
    func setupForWelcomeVideo() {
        
        smallAvatar.isHidden = true
        avatar.isHidden = true
        timeAvatar.isHidden = false
        button.isHidden = true
        buttonWidth.constant = 0
        rate.isHidden = true
        
        setLabelText(normal: "More sent you a video: ", bold: "Say Hello to the Times of your life!")
        timeAvatar.type = .magical
        timeAvatar.progress = 1
        timeAvatar.image = UIImage(named: "welcome")
    }
    
    func setup(photo: String, text: String) {
        
        smallAvatar.isHidden = true
        avatar.isHidden = false
        timeAvatar.isHidden = true
        button.isHidden = true
        buttonWidth.constant = 60
        rate.isHidden = true
        
        setLabelText(normal: text, bold: "")
        avatar.sd_progressive_setImage(with: URL(string: photo), placeholderImage: UIImage.profileThumbPlaceholder())
    }
    
    
    
    private func setLabelText(normal: String, bold: String) {
        
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        var part = NSAttributedString(
            string: normal,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 124, green: 139, blue: 155),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Heavy", size: 14) ?? UIFont.systemFont(ofSize: 14)
        part = NSAttributedString(
            string: bold,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 67, green: 74, blue: 81),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        label.attributedText = text
    }

}
