//
//  SignalTopBar.swift
//  More
//
//  Created by Luko Gjenero on 09/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceTopBar: LoadableView {

    @IBOutlet private weak var avatars: AvatarStackView!
    @IBOutlet private weak var additional: UILabel!
    @IBOutlet private weak var additionalWidth: NSLayoutConstraint!
    @IBOutlet private weak var label: HorizontalGradientLabel!
    @IBOutlet private weak var walking: UIView!
    @IBOutlet private weak var walkLabel: UILabel!
    @IBOutlet private weak var avatarButton: UIButton!
    
    var profileTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        additional.layer.cornerRadius = 17.5
        additional.layer.masksToBounds = true
        
        label.gradientColors = [UIColor.brightSkyBlue.cgColor, UIColor(red: 76, green: 171, blue: 255).cgColor]
        walking.addWalkingAnimation()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        avatars.setup(for: ["https://www.pexels.com/photo/face-facial-hair-fine-looking-guy-614810/"])
        
        label.text = "John Doe"
        
        walking.isHidden = false
        walkLabel.text = "250 ft away"
    }
    
    func setup(for experience: Experience) {
        isHidden = false

        var users: [ShortUser] = []
        if let post = experience.activePost() {
            users.append(post.creator.short())
            for request in post.requests ?? [] {
                if request.accepted == true {
                    users.append(request.creator)
                }
            }
        } else {
            users.append(experience.creator.short())
        }
        
        avatars.setup(for: users.map { $0.avatar })
        
        if users.count > 3 {
            additionalWidth.constant = 35
            additional.isHidden = false
            additional.text = "\(users.count - 3)+"
        } else {
            additionalWidth.constant = 4
            additional.isHidden = true
        }

        var text = "\(users.first?.name ?? "")"
        if users.count > 2 {
            text += " & \(users.count - 1) others"
        } else if users.count > 1 {
            text += " & 1 other"
        }
        label.text = text
        
        if users.count <= 1,
            let location = experience.activePost()?.location ?? experience.destination,
            let myLocation = LocationService.shared.currentLocation {
            walking.isHidden = false
            walking.lottieView?.play()
            let distance = myLocation.distance(from: location.location())
            walkLabel.text = "\(Formatting.formatFeetAway(distance.metersToFeet())) away"
        } else {
            walking.isHidden = true
            walkLabel.text = ""
        }
    }
    
    func setupEmpty() {
        isHidden = true
        
        avatars.setupForEmpty()
        
        label.text = ""
        
        walking.isHidden = true
        walkLabel.text = ""
    }
    
    func setupForMore(title: String) {
        isHidden = true
        
        avatars.setupForMore()
        
        label.text = title
        
        walking.isHidden = true
        walkLabel.text = ""
    }
    
    @IBAction private func profileTouch(_ sender: Any) {
        profileTap?()
    }
}
