//
//  CreateSignalDestinationCell.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalDestinationCell: CreateSignalBaseCell {

    static let height: CGFloat = 30
    
    @IBOutlet private weak var label: UILabel!
    
    // MARK: - base
    
    override class func size(for model: CreateExperienceViewModel, in size: CGSize, keyboardVisible: Bool) -> CGSize {
        return CGSize(width: size.width, height: CreateSignalDestinationCell.height)
    }
    
    override class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        return /* model.somewhere || */  model.destination != nil
    }
    
    override func setup(for model: CreateExperienceViewModel, keyboardVisible: Bool) {
        if model.somewhere {
            label.text = "SOMEWHERE CLOSE"
        } else {
            label.text = model.destinationName?.uppercased()
        }
    }
    
}
