//
//  ReviewSegmentHeader.swift
//  More
//
//  Created by Luko Gjenero on 23/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ReviewSegmentHeader: LoadableView {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    
    func setup(title: String, subtitle: String) {
        self.title.text = title
        self.subtitle.text = subtitle
    }
}
