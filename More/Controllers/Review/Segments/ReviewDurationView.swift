//
//  ReviewDurationView.swift
//  More
//
//  Created by Luko Gjenero on 24/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ReviewDurationView: LoadableView {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var selection: UIButton!
    
    var duration: Review.Duration = .underAnHour {
        didSet {
            title.text = duration.rawValue.capitalized
        }
    }
    
    func setupSelected(_ selected: Bool) {
        selection.isSelected = selected
        backgroundColor = selected ? .white : .clear
    }

}
