//
//  ChatViewJoinCallBar.swift
//  More
//
//  Created by Luko Gjenero on 08/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

private let interval: TimeInterval = 0.5

@IBDesignable
class ChatViewJoinCallBar: LoadableView {

    @IBOutlet private weak var joinButton: PurpleGradientAndRedButton!
    @IBOutlet private weak var callView: UIView!
    @IBOutlet private weak var callLabel: UILabel!
    
    private var createdAt: TimeInterval = 0
    private weak var timer: Timer?
    
    var jointTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        joinButton.layer.masksToBounds = true
        joinButton.layer.cornerRadius = 18
    }
    
    @IBAction private func joinButtonTouch(_ sender: Any) {
        jointTap?()
    }
    
    func setup(for chat: Chat, canJoin: Bool) {
        if canJoin {
            joinButton.setTitle("JOIN CALL", for: .normal)
            joinButton.setupPurpleGradient()
        } else {
            joinButton.setTitle("LEAVE CALL", for: .normal)
            joinButton.setupRed()
        }
        setupTimer(for: chat)
    }
    
    private func setupTimer(for chat: Chat) {
        timer?.invalidate()
        createdAt = chat.videoCall?.createdAt.timeIntervalSince1970 ?? 0
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] (timer) in
            
            guard let createdAt = self?.createdAt else { timer.invalidate(); return }
            guard let label = self?.callLabel else { timer.invalidate(); return }
            
            let now = Date().timeIntervalSince1970
            
            let timePast = Int(now - createdAt)
            let hours = timePast / 3600
            let minutes = (timePast / 60) % 60
            let seconds = timePast % 60
            
            if hours > 0 {
                label.text = "\(hours):\(String(format: "%02d",minutes)):\(String(format: "%02d", seconds))"
            } else {
                label.text = "\(minutes):\(String(format: "%02d", seconds))"
            }
        })
        
    }

}
