//
//  ReviewCommentPage.swift
//  More
//
//  Created by Luko Gjenero on 24/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewCommentPage: ReviewPage {

    @IBOutlet private weak var commentView: ReviewCommentView!
    
    private var model: CreateReviewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        
        commentView.textChanged = { [weak self] (text) in
            self?.model?.comment = text
            self?.dataChanged?()
        }
    }
    
    override func setup(for model: CreateReviewModel) {
        self.model = model
        commentView.setup(for: model)
    }

}
