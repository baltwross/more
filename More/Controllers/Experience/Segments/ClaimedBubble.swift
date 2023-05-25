//
//  ClaimedBubble.swift
//  More
//
//  Created by Luko Gjenero on 07/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ClaimedBubble: LoadableView {

    @IBOutlet private weak var blur: UIVisualEffectView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var clock: UIView!
    @IBOutlet private weak var time: HorizontalGradientLabel!
    
    override func setupNib() {
        super.setupNib()
        
        blur.layer.cornerRadius = 45
        blur.layer.masksToBounds = true
        
        time.gradientColors = [UIColor(red: 3, green: 255, blue: 191).cgColor,
                               UIColor.brightSkyBlue.cgColor,
                               UIColor(red: 48, green: 183, blue: 255).cgColor,
                               UIColor.lightPeriwinkle.cgColor]
        time.gradientLocations = [0, 0.32, 0.6, 1]
        
        clock.addClockAnimation(dark: false)
        clock.lottieView?.play()
    }
    
    func setup(for experience: Experience) {
        setupTitle(experience.title)
        setupTime(ConfigService.shared.experiencePostExpiration)
    }
    
    private func setupTitle(_ name: String) {
        let text = NSMutableAttributedString()
               
       var font = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
       var part = NSAttributedString(
           string: "You’ve successfully activated ",
           attributes: [NSAttributedString.Key.foregroundColor : UIColor.blueGrey,
                        NSAttributedString.Key.font : font])
       text.append(part)
       
       font = UIFont(name: "Gotham-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
       part = NSAttributedString(
           string: name + ".",
           attributes: [NSAttributedString.Key.foregroundColor : UIColor.charcoalGrey,
                        NSAttributedString.Key.font : font])
       text.append(part)
        
        title.attributedText = text
    }
    
    private func setupTime(_ duration: TimeInterval) {
        let minutes = Int(duration / 60)
        time.text = "It will be live for \(minutes) minutes."
    }

}
