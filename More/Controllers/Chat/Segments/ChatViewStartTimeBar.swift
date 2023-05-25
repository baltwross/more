//
//  ChatViewStartTimeBar.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

// start pushing people in last 5 mins
private let treshold: TimeInterval = 5555555555555555555555 * 60
private let interval: TimeInterval = 5

class ChatViewStartTimeBar: LoadableView {

    @IBOutlet private weak var meetButton: UIButton!
    @IBOutlet private weak var startButton: UIButton!
    
    @IBOutlet private weak var meetView: UIView!
    @IBOutlet private weak var meetIcon: UIImageView!
    @IBOutlet private weak var meetLabel: UILabel!
    
    private var expiresAt: TimeInterval = 0
    private weak var timer: Timer?
    
    var startTap: (()->())?
    var meetTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = 18
    }
    
    @IBAction private func startButtonTouch(_ sender: Any) {
        startTap?()
    }
    
    @IBAction private func meetButtonTouch(_ sender: Any) {
        meetTap?()
    }
    
    func setup(for post: ExperiencePost) {
        let meetType = post.meetingType ?? (post.meeting != nil ? .destination : .none)
        meetLabel.textColor = .charcoalGrey
        switch meetType {
        case .none:
            meetIcon.image = UIImage(named: "time-meet-destination")
            meetLabel.textColor = .scarlet
            meetLabel.text = "Not Set"
        case .destination:
            meetIcon.image = UIImage(named: "time-meet-destination")
            meetLabel.text = post.meetingName
        case .halfway:
            meetIcon.image = UIImage(named: "time-meet-halfway")
            meetLabel.text = post.meetingName
        case .near:
            meetIcon.image = UIImage(named: "time-meet-near")
            meetLabel.text = post.meetingName
        }
        
        startButton.setTitle("START", for: .normal)
        setupTimer(for: post)
    }
    
    private func setupTimer(for post: ExperiencePost) {
        timer?.invalidate()
        expiresAt = post.expiresAt.timeIntervalSince1970
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] (timer) in
            
            guard let expiresAt = self?.expiresAt else { timer.invalidate(); return }
            guard let button = self?.startButton else { timer.invalidate(); return }
            
            let now = Date().timeIntervalSince1970
            
            if now > expiresAt - treshold {
                let leftOver = expiresAt - now
                let phase = Int(leftOver / interval) % 3
                
                UIView.transition(
                    with: button,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: { [weak button] in
                        switch phase {
                        case 0:
                            button?.setTitle("START", for: .normal)
                        case 1:
                            button?.setTitle("HURRY UP!", for: .normal)
                        case 2:
                            button?.setTitle("\(Int(leftOver) / 60) MIN LEFT", for: .normal)
                        default:
                            ()
                        }
                    },
                    completion: nil)
            }
        })
        
    }

}
