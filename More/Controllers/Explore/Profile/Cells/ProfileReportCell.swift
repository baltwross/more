//
//  ProfleReportCell.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileReportCell: ProfileBaseCell {

    static let height: CGFloat = 90
    
    @IBOutlet weak var label: UILabel!
    
    // MARK: - base
    
    override func setup(for model: UserViewModel) {
        let text = "\(model.name.uppercased())'S GONE ON \(model.numOfGoings) \(model.numOfGoings == 1 ? "TIME." : "TIMES.")"
        label.text = text
    }
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ProfileReportCell.height)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return true
    }
    
}
