//
//  ChatTypingCell.swift
//  More
//
//  Created by Luko Gjenero on 31/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Lottie

class ChatTypingCell: ChatBaseCell {

    @IBOutlet private weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAnimation()
    }
    
    private func setupAnimation() {
        if let path = Bundle.main.path(forResource: "typing-indicator", ofType: "json", inDirectory: "Animations/typing") {
            let lottieView = LottieAnimationView(filePath: path)
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = .loop
            containerView.addSubview(lottieView)
            lottieView.translatesAutoresizingMaskIntoConstraints = false
            lottieView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            lottieView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            lottieView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            lottieView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            
            lottieView.play()
        }
    }
    
}
