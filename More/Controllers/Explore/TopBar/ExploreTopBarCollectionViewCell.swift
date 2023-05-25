//
//  ExploreTopBarCollectionViewCell.swift
//  More
//
//  Created by Luko Gjenero on 14/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ExploreTopBarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var signalBar: ExperienceTopBar!
    
    var profileTap: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        signalBar.profileTap = { [weak self] in
            self?.profileTap?()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.transform = CATransform3DIdentity
    }
    
    func setup(for experience: Experience) {
        if experience.activePost() == nil {
            signalBar.setupForMore(title: "Claim This Signal")
        } else {
            signalBar.setup(for: experience)
        }
    }
    
    func setupEmpty() {
        signalBar.setupEmpty()
    }

}
