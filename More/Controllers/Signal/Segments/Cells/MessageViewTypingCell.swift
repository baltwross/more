//
//  MessageViewTypingCell.swift
//  More
//
//  Created by Luko Gjenero on 30/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Lottie

class MessageViewTypingCell: MessagingViewBaseCell {

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
    
    // MARK: - base
    
    override class func size(for model: MessageViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: model.isTyping == true ? 54 : 0)
    }
    
    override class func isShowing(for model: MessageViewModel) -> Bool {
        return model.isTyping == true
    }
    
    override func setup(for model: MessageViewModel) {
        // nothing
    }
    
    override var isEditable: Bool {
        get {
            return false
        }
        set {
            // nothing
        }
    }
    
}
