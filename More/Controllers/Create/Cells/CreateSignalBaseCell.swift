//
//  CreateSignalBaseCell.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalBaseCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var resize: (()->())?
    
    class func size(for model: CreateExperienceViewModel, in size: CGSize, keyboardVisible: Bool) -> CGSize {
        return .zero
    }
    
    class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        return false
    }
    
    func setup(for model: CreateExperienceViewModel, keyboardVisible: Bool) { }
}
