//
//  ProfileBaseCell.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileBaseCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return .zero
    }
    
    class func isShowing(for model: UserViewModel) -> Bool {
        return false
    }
    
    func setup(for model: UserViewModel) { }

}
