//
//  ProfileUserCell.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileUserCell: ProfileBaseCell {

    static let height: CGFloat = 45
    
    @IBOutlet private weak var verified: UIImageView!
    @IBOutlet private weak var nameAndAge: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - base
    
    override func setup(for model: UserViewModel) {
        
        verified.image = UIImage(named: "verified")
        
        let text = NSMutableAttributedString()
        
        let firstBlockAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.brightSkyBlue,
            .font : UIFont(name: "Gotham-Black", size: 12)!,
            .kern : 2
        ]
        let secondBlockAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.blueGrey,
            .font : UIFont(name: "Gotham-Bold", size: 13)!
        ]
        
        var part = NSAttributedString(
            string: "\(model.name)",
            attributes: firstBlockAttrs)
        text.append(part)
        
        if model.age > 0 {
            part = NSAttributedString(
                string: ", ",
                attributes: firstBlockAttrs)
            text.append(part)
            
            part = NSAttributedString(
                string: "\(model.age)",
                attributes: secondBlockAttrs)
            text.append(part)
        }
        
        nameAndAge.attributedText = text
    }
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ProfileUserCell.height)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return true
    }
}
