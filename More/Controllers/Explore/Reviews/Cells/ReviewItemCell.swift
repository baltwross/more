//
//  ReviewItemCell.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewItemCell: UITableViewCell {

    @IBOutlet private weak var header: SignalReviewHeader!
    @IBOutlet private weak var bubble: SignalReviewBubble!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        bubble.enableReadMore = false
    }
    
    func setup(for model: ReviewViewModel) {
        header.setup(for: model)
        bubble.setup(for: model)
    }
    
    class func size(for model: ReviewViewModel, in size: CGSize) -> CGSize {
        
        let headerHeight = SignalReviewHeader.size(for: model, in: CGSize(width: size.width - 50, height: size.height)).height
        let bubbleHeight = SignalReviewBubble.size(for: model, in: CGSize(width: size.width - 50, height: size.height)).height
        return CGSize(width: size.width, height: 18 + headerHeight + 12 + bubbleHeight + 18)
    }
}
