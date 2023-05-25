//
//  ProfileMoreCell.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileMoreCell: ProfileBaseCell {
    
    static let height: CGFloat = 45
    
    @objc enum MoreType: Int {
        case reviews
    }
    
    @IBOutlet private weak var label: UILabel!
    
    @IBInspectable var type: Int = MoreType.reviews.rawValue {
        didSet {
            guard let type = MoreType(rawValue: type) else { return }
            switch type {
            case .reviews:
                setupForReviews()
            }
        }
    }
    
    private func setupForReviews() {
        label.text = "Read More"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - base
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ProfileMoreCell.height)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return model.numOfReviews > 0
    }
}
