//
//  ProfileMomentCell.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ProfileMomentCell: ProfileBaseCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    
    // MARK: - base
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        let titleFont = UIFont(name: "Gotham-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)
        let titleHeight = "More Moment".height(withConstrainedWidth: 1024, font: titleFont) + 1
        let subtitleFont = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let subtitleHeight = model.memory.height(withConstrainedWidth: size.width - 50, font: subtitleFont) + 1
        
        return CGSize(width: size.width, height: 90 + titleHeight + subtitleHeight)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return !model.memory.isEmpty
    }
    
    override func setup(for model: UserViewModel) {
        subtitle.text = model.memory
    }
}
