//
//  ExperienceRequestSingleBar.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceRequestSingleBar: LoadableView {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var info: UIView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var walking: UIView!
    @IBOutlet private weak var distance: UILabel!
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet weak var joinButton: PurpleGradientAndRedButton!
    
    var profileTap: (()->())?
    var joinTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        joinButton.layer.masksToBounds = true
        joinButton.layer.cornerRadius = 25
        
        walking.addWalkingAnimation()
        walking.lottieView?.play()
    }
    
    @IBAction private func profileTouch(_ sender: Any) {
        profileTap?()
    }
    
    @IBAction private func joinTouch(_ sender: Any) {
        joinTap?()
    }
    
    func setup(for post: ExperiencePost) {
        avatar.sd_progressive_setImage(with: URL(string: post.creator.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        info.isHidden = false
        name.text = post.creator.name
        distance.text = "..."
        loadDistance(from: post.creator.short())
        
        if post.creator.isMe() {
            joinButton.setupRed()
            joinButton.setTitle("LEAVE", for: .normal)
        }
    }
    
    private func loadDistance(from user: ShortUser) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        GeoService.shared.getDistance(from: myId, to: user.id) { [weak self] (distance) in
            self?.distance.text = "\(Formatting.formatFeetAway(distance.metersToFeet())) away"
        }
    }
    
    func setupForConfirm() {
        joinButton.setTitle("CONFIRM", for: .normal)
    }
    
    func setupForRequest() {
        joinButton.setTitle("JOIN", for: .normal)
    }

}
