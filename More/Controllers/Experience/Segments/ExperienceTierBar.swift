//
//  ExperienceTierBar.swift
//  More
//
//  Created by Luko Gjenero on 02/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceTierBar: LoadableView {
    
    @IBOutlet private weak var leadAvatar: AvatarImage!
    @IBOutlet private weak var restAvatar: AvatarImage!
    @IBOutlet private weak var profileButton: UIButton!
    @IBOutlet private weak var info: UIView!
    @IBOutlet private weak var price: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var joinButton: PurpleGradientAndGreyButton!
    
    var infoTap: (()->())?
    var profileTap: (()->())?
    var joinTap: (()->())?
    
    private var post: ExperiencePost?
    
    override func setupNib() {
        super.setupNib()
        
        joinButton.layer.masksToBounds = true
        joinButton.layer.cornerRadius = 25
        
        NotificationCenter.default.addObserver(self, selector: #selector(safeSetupPrice), name: InAppPurchaseService.Notifications.ProductsLoaded, object: nil)
    }
    
    @IBAction private func infoTouch(_ sender: Any) {
        infoTap?()
    }
    
    @IBAction private func profileTouch(_ sender: Any) {
        profileTap?()
    }
    
    @IBAction private func joinTouch(_ sender: Any) {
        joinTap?()
    }
    
    func setup(for post: ExperiencePost?) {
        self.post = post
        
        guard let post = post else {
            leadAvatar.sd_cancelCurrentImageLoad_progressive()
            restAvatar.sd_cancelCurrentImageLoad_progressive()
            price.text = "..."
            return
        }
    
        leadAvatar.sd_progressive_setImage(with: URL(string: post.creator.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        if let request = post.requests?.first(where: { $0.accepted == true }) {
            restAvatar.isHidden = false
            restAvatar.sd_progressive_setImage(with: URL(string: request.creator.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        } else {
            restAvatar.isHidden = true
            restAvatar.sd_cancelCurrentImageLoad_progressive()
        }
        
        price.text = "..."
        setupPrice()
    }
    
    func setupForSoldOut() {
        joinButton.setupGrey()
        joinButton.setTitle("SOLD OUT", for: .normal)
        joinButton.isUserInteractionEnabled = false
        infoLabel.text = "Join Waitlist"
    }
    
    func setupForPurchased() {
        price.text = "Purchased"
        joinButton.setTitle("ENTER", for: .normal)
    }
    
    @objc private func safeSetupPrice() {
        DispatchQueue.main.async { [weak self] in
            self?.setupPrice()
        }
    }
    
    private func setupPrice() {
        guard let post = post,
            let tier = post.experience.tier,
            let skProduct = InAppPurchaseService.shared.skProduct(for: tier.id)
            else {
            price.isHidden = true
            return
        }

        price.isHidden = false
        price.text = skProduct.localizedPrice
    }
    
    func setupForConfirm() {
        joinButton.setTitle("CONFIRM", for: .normal)
    }
    
    func setupForRequest() {
        joinButton.setTitle("JOIN", for: .normal)
    }

}
