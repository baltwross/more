//
//  ReviewSubmittedPage.swift
//  More
//
//  Created by Luko Gjenero on 25/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewSubmittedPage: ReviewPage {

    @IBOutlet private weak var header : ReviewSegmentHeader!
    
    private var model: CreateReviewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func setup(for model: CreateReviewModel) {
        self.model = model
        let title = ""
        let subtitle = "Thank you for reviewing your Time with \(model.time.otherPerson().name)."
        header.setup(title: title, subtitle: subtitle)
    }

}
