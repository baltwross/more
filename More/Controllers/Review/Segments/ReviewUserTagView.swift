//
//  ReviewUserTagView.swift
//  More
//
//  Created by Luko Gjenero on 24/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ReviewUserTagView: LoadableView {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    @IBOutlet private weak var selection: UIButton!
    
    var tagType: Review.Tag = .adventurous {
        didSet {
            title.text = tagType.rawValue.capitalized
            subtitle.text = tagType.description
        }
    }
    
    func setupSelected(_ selected: Bool) {
        selection.isSelected = selected
    }

}
