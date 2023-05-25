//
//  ProfileDesignedExperiencesCell.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ProfileDesignedExperiencesCell: ProfileBaseCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    
    // MARK: - base
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 90)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return model.user.isMe() && model.numOfDesigned > 0
    }
    
    override func setup(for model: UserViewModel) {
        subtitle.text = "YOU'VE CREATED \(model.numOfDesigned) TIMES"
    }
}
