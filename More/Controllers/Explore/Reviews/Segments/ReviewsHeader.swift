//
//  ReviewsHeader.swift
//  More
//
//  Created by Luko Gjenero on 14/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ReviewsHeader: LoadableView {

    @IBOutlet private weak var title: SpecialLabel!
    @IBOutlet private weak var rate: StarsView!
    @IBOutlet private weak var numberOfReviews: SpecialLabel!
    @IBOutlet private weak var button: UIButton!
    
    @IBOutlet private weak var leftPadding: NSLayoutConstraint!
    @IBOutlet private weak var height: NSLayoutConstraint!
    @IBOutlet private weak var rateWidth: NSLayoutConstraint!
    
    var backTap: (()->())?
 
    @IBAction private func buttonTouch(_ sender: UIButton) {
        backTap?()
    }
    
    func setup(for model: UserViewModel) {
        title.text  = "\(model.name.uppercased())'S TIMES"
        rate.rate = CGFloat(model.avgReview)
        numberOfReviews.text = "\(model.numOfReviews)"
    }
    
    func setupOffset(_ offset: CGFloat) {
        if offset <= 0 {
            leftPadding.constant = 25
            height.constant = 100
            rateWidth.constant = 90
            rate.padding = 10
        } else if offset >= 50 {
            leftPadding.constant = 50
            height.constant = 50
            rateWidth.constant = 70
            rate.padding = 5
        } else {
            let progress = offset / 50
            leftPadding.constant = 25 + 25 * progress
            height.constant = 100 - 50 * progress
            rateWidth.constant = 90 - 20 * progress
            rate.padding = 10 - 5 * progress
        }
        superview?.layoutIfNeeded()
    }

}
