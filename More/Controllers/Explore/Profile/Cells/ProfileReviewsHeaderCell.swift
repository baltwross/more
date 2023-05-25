//
//  ProfileReviewsHeaderCell.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileReviewsHeaderCell: ProfileBaseCell {

    static let height: CGFloat = 50
   
    @IBOutlet weak var title: UILabel!
    
    // MARK: - base
    
    override func setup(for model: UserViewModel) {
        title.text = "PAST TIMES"
    }

    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ProfileReviewsHeaderCell.height)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return model.numOfReviews > 0
    }
    
}
