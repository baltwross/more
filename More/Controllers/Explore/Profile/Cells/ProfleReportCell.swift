//
//  ProfleReportCell.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileReportCell: ProfileBaseCell {

    static let height: CGFloat = 116
    
    @IBOutlet weak var label: UILabel!
    
    
    // MARK: - base
    
    override func setup(for model: UserViewModel) {
        
        let text = NSMutableAttributedString()
        
        var part = NSAttributedString(
            string: "\(model.name) has gone on",
            attributes: [NSAttributedStringKey.foregroundColor : label.textColor,
                         NSAttributedStringKey.font : label.font])
        text.append(part)
        
        var font = UIFont(name: "DIN-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
        part = NSAttributedString(
            string: " \(model.numOfGoings) ",
            attributes: [NSAttributedStringKey.foregroundColor : Colors.lightBlueHighlight,
                         NSAttributedStringKey.font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Heavy", size: 14) ?? UIFont.systemFont(ofSize: 14)
        part = NSAttributedString(
            string: "times.",
            attributes: [NSAttributedStringKey.foregroundColor : Colors.lightBlueHighlight,
                         NSAttributedStringKey.font : font])
        text.append(part)
        
        label.attributedText = text
    }
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ProfileReportCell.height)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return true
    }
    
}
