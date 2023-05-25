//
//  ReviewTimePage.swift
//  More
//
//  Created by Luko Gjenero on 23/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewTimePage: ReviewPage {

    @IBOutlet private weak var header : ReviewSegmentHeader!
    @IBOutlet private weak var stars : StarsView!
    
    private var switchedStars = false
    private var model: CreateReviewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        header.setup(title: "The Time", subtitle: "How was the experience?")
        
        stars.noStar = UIImage(named: "star_outline")
        
        stars.rateSelected = { [weak self] (rate) in
            if self?.switchedStars == false {
                self?.switchedStars = true
                self?.stars.noStar = UIImage(named: "no_star_2")
            }
            self?.model?.timeRate = Int(rate)
            self?.dataChanged?()
        }
    }

    override func setup(for model: CreateReviewModel) {
        self.model = model
        
        let timeRate = CGFloat(model.timeRate ?? 0)
        if timeRate > 0 {
            switchedStars = true
            stars.noStar = UIImage(named: "no_star_2")
        } else {
            switchedStars = false
            stars.noStar = UIImage(named: "star_outline")
        }
        stars.rate = timeRate
    }

}
