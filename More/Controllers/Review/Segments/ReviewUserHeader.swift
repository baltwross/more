//
//  ReviewUserHeader.swift
//  More
//
//  Created by Luko Gjenero on 23/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewUserHeader: LoadableView {

    @IBOutlet private weak var top: ReviewUserHeaderTop!
    @IBOutlet private weak var bottom: ReviewUserHeaderBottom!
    
    var avatarTap: (()->())?
    var timeTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        top.avatarTap = { [weak self] in
            self?.avatarTap?()
        }
        bottom.tap = { [weak self] in
            self?.timeTap?()
        }
    }
    
    
    func setup(for time: Time) {
        top.setup(for: time.otherPerson())
        bottom.setup(for: time)
    }
    
    func setupStep(_ step: Int, of stepNum: Int) {
        top.setupStep(step, of: stepNum)
    }
    
    func setupForSubmitted() {
        top.setupThanks()
        bottom.setupForSubmitted()
    }
}
