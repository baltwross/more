//
//  ProfileQandACell.swift
//  More
//
//  Created by Luko Gjenero on 27/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileQandACell: ProfileBaseCell {
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var memory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTitle()
    }
    
    private func setupTitle() {
        
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Avenir-Heavy", size: 18) ?? UIFont.systemFont(ofSize: 18)
        var part = NSAttributedString(
            string: "Q",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 124, green: 139, blue: 155),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Light", size: 14) ?? UIFont.systemFont(ofSize: 14)
        part = NSAttributedString(
            string: " & ",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 101, green: 111, blue: 121),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Heavy", size: 18) ?? UIFont.systemFont(ofSize: 18)
        part = NSAttributedString(
            string: "A",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 124, green: 139, blue: 155),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        title.attributedText = text
    }
    
    // MARK: - base
    
    override func setup(for model: UserViewModel) {
        memory.text = model.memory
    }
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        let font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        let memoryHeight = model.memory.height(withConstrainedWidth: size.width - 50, font: font) + 1
        return CGSize(width: size.width, height: 170 + memoryHeight)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return model.memory.count > 0
    }

}
