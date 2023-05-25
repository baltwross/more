//
//  LoginInviteToGetInViewController.swift
//  More
//
//  Created by Luko Gjenero on 30/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import WebKit
import Lottie
import Firebase

class LoginInviteToGetInViewController: BaseLoginViewController {

    @IBOutlet private weak var topBar: BackgroundWithOval!
    @IBOutlet private weak var superTitle: UILabel!
    @IBOutlet private weak var titleView: UILabel!
    @IBOutlet private weak var clock: UIView!
    @IBOutlet private weak var counterView: UILabel!
    @IBOutlet private weak var animationContainer: UIView!
    @IBOutlet private weak var inviteTitle: UILabel!
    @IBOutlet private weak var inviteMessage: UILabel!
    @IBOutlet private weak var linkContainer: UIView!
    @IBOutlet private weak var linkView: CopyableLabel!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    private var count: Int = 565
    private var limit: Int = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupClock()
        setupCounter()
        loadLottie()
        
        linkContainer.layer.masksToBounds = true
        linkContainer.layer.cornerRadius = 26.5
        
        updateSubmitButton(dark: false)
        
        if let inviteLink = ProfileService.shared.profile?.inviteLink {
            setupWithLink(inviteLink)
        } else {
            createLink()
        }
    }
    
    @IBAction func submitTouch(_ sender: Any) {
        if let link = linkView.text, link.count > 0 {
            ProfileService.shared.updateInviteLink(link)
            nextView?()
        }
    }
    
    @IBAction func shareTouch(_ sender: Any) {
        if let link = linkView.text, link.count > 0 {
            shareLink()
        }
    }
    
    private func updateSubmitButton(dark: Bool) {
        if dark {
            submitButton.backgroundColor = Colors.previewDarkBackground
            submitButton.setTitleColor(Colors.previewDarkText, for: .normal)
        } else {
            submitButton.backgroundColor = Colors.previewLightBackground
            submitButton.setTitleColor(Colors.previewLightText, for: .normal)
        }
    }
    
    private func setupWithLink(_ inviteLink: String) {
        linkView.text = inviteLink
        updateSubmitButton(dark: true)
    }
    
    private func createLink() {
        LinkService.inviteLink { [weak self] (url) in
            self?.setupWithLink(url.absoluteString)
        }
    }
    
    private func shareLink() {
        ShareService.shareInvite(from: self)
    }
    
    private func setupClock() {
        if let path = Bundle.main.path(forResource: "dark-timer", ofType: "json", inDirectory: "Animations/dark-timer") {
            let lottieView = LottieAnimationView(filePath: path)
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = .loop
            clock.addSubview(lottieView)
            lottieView.translatesAutoresizingMaskIntoConstraints = false
            lottieView.topAnchor.constraint(equalTo: clock.topAnchor).isActive = true
            lottieView.bottomAnchor.constraint(equalTo: clock.bottomAnchor).isActive = true
            lottieView.leadingAnchor.constraint(equalTo: clock.leadingAnchor).isActive = true
            lottieView.trailingAnchor.constraint(equalTo: clock.trailingAnchor).isActive = true
            lottieView.play()
        }
    }
    
    private func setupCounter() {
        
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Arial-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        var part = NSAttributedString(
            string: "NO.",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                         NSAttributedString.Key.kern : 4.38,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
        part = NSAttributedString(
            string: "\(count)",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.white,
                         NSAttributedString.Key.kern : 2,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        part = NSAttributedString(
            string: " / \(limit)",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x0bfc3ca),
                         NSAttributedString.Key.kern : 0,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        counterView.attributedText = text
    }
    
    
    private func loadLottie(_ forceAnimation: String? = nil) {
        
        var animation = "rambo-3"
        if count < limit / 3 {
            animation = "rambo-1"
        } else if count < limit * 2 / 3 {
            animation = "rambo-2"
        }
        
        if let forceAnimation = forceAnimation {
            animation = forceAnimation
        }
        
        if let path = Bundle.main.path(forResource: animation, ofType: "json", inDirectory: "Animations/\(animation)") {
            let lottieView = LottieAnimationView(filePath: path)
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = .loop
            animationContainer.subviews.forEach { $0.removeFromSuperview() }
            animationContainer.addSubview(lottieView)
            lottieView.translatesAutoresizingMaskIntoConstraints = false
            lottieView.setContentHuggingPriority(.defaultLow, for: .vertical)
            lottieView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            lottieView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            lottieView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            lottieView.topAnchor.constraint(equalTo: animationContainer.topAnchor).isActive = true
            lottieView.bottomAnchor.constraint(equalTo: animationContainer.bottomAnchor).isActive = true
            lottieView.leadingAnchor.constraint(equalTo: animationContainer.leadingAnchor).isActive = true
            lottieView.trailingAnchor.constraint(equalTo: animationContainer.trailingAnchor).isActive = true
            
            lottieView.play()
        }
     
    }
    
    // MARK; - beta
    
    func setupForBeta() {
        counterView.attributedText = nil
        counterView.text = nil
        inviteMessage.text = "Thank you for participating in More's Beta Program. Invite your friends to help More go live sooner."
        loadLottie("rambo-1")
        submitButton.removeTarget(nil, action: nil, for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(shareTouch(_:)), for: .touchUpInside)
    }
 
}
