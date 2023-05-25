//
//  SignalTipView.swift
//  More
//
//  Created by Luko Gjenero on 29/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class SignalTipView: LoadableView {

    @IBOutlet private weak var tip: UILabel!
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var votes: UILabel!
    
    @IBOutlet private weak var upVoteButton: UIButton!
    @IBOutlet private weak var downVoteButton: UIButton!
    private var score: Int = 0
    
    var upVote: (()->())?
    var downVote: (()->())?
    
    @IBAction private func upVoteTouch(_ sender: Any) {
        upVote?()
        upVoteButton.isSelected = true
        votes.text = "\(score + 1)"
        votes.textColor = .cornflower
        enableVoting(false)
    }
    
    @IBAction private func downVoteTouch(_ sender: Any) {
        downVote?()
        downVoteButton.isSelected = true
        votes.text = "\(score - 1)"
        votes.textColor = .scarlet
        enableVoting(false)
    }
    
    private func enableVoting(_ enable: Bool) {
        upVoteButton.isUserInteractionEnabled = enable
        downVoteButton.isUserInteractionEnabled = enable
    }
    
    func setup(for tip: ExperienceTip) {
        
        self.tip.text = tip.text
        
        if let url = URL(string: tip.creator.avatar) {
            avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder(), options: .highPriority)
        } else {
            avatar.sd_cancelCurrentImageLoad_progressive()
            avatar.image = nil
        }
        name.text = tip.creator.name
        
        let df = DateFormatter()
        df.dateFormat = "MMM YYYY"
        date.text = df.string(from: tip.createdAt)
        
        var score = tip.upvote?.count ?? 0
        score -= tip.downvote?.count ?? 0
        self.score = score
        votes.textColor = UIColor(red: 191, green: 195, blue: 202)
        votes.text = "\(score)"
        
        let myId = ProfileService.shared.profile?.id ?? "-"
        if tip.upvote?.contains(myId) == true {
            upVoteButton.isSelected = true
            downVoteButton.isSelected = false
            votes.textColor = .cornflower
            enableVoting(false)
        } else if tip.downvote?.contains(myId) == true {
            upVoteButton.isSelected = false
            downVoteButton.isSelected = true
            votes.textColor = .scarlet
            enableVoting(false)
        } else {
            upVoteButton.isSelected = false
            downVoteButton.isSelected = false
            votes.textColor = .lightBlueGrey
            enableVoting(true)
        }
    }
    

}
