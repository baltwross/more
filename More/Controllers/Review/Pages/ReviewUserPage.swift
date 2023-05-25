//
//  ReviewUserPage.swift
//  More
//
//  Created by Luko Gjenero on 24/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewUserPage: ReviewPage {

    @IBOutlet private weak var header : ReviewSegmentHeader!
    @IBOutlet private weak var stars : StarsView!
    
    private var switchedStars = false
    private var model: CreateReviewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        stars.noStar = UIImage(named: "star_outline")
        
        stars.rateSelected = { [weak self] (rate) in
            if self?.switchedStars == false {
                self?.switchedStars = true
                self?.stars.noStar = UIImage(named: "no_star_2")
            }
            self?.model?.userRate = Int(rate)
            self?.dataChanged?()
        }
    }
    
    override func setup(for model: CreateReviewModel) {
        self.model = model
        let subtitle = "How safe and comfortable did you feel in \(model.time.otherPerson().name)'s company?"
        header.setup(
            title: model.time.otherPerson().name,
            subtitle: subtitle)
        
        let userRate = CGFloat(model.userRate ?? 0)
        if userRate > 0 {
            switchedStars = true
            stars.noStar = UIImage(named: "no_star_2")
        } else {
            switchedStars = false
            stars.noStar = UIImage(named: "star_outline")
        }
        stars.rate = userRate
        
    }

}
