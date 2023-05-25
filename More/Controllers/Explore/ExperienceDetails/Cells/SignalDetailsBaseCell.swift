//
//  SignalDetailsBaseCell.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class SignalDetailsBaseCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    // MARK: - experience details view
    
    class func isShowing(for experience: Experience) -> Bool {
        return false
    }
    
    func setup(for experience: Experience) { }
    
    // MARK: - signal preview
    
    class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        return false
    }
    
    func setup(for model: CreateExperienceViewModel) { }
}


