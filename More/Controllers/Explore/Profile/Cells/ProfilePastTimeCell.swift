//
//  ProfilePastTimeCell.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

class ProfilePastTimeCell: ProfileBaseCell {

    static let height: CGFloat = 86
    
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var note: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatar.layer.masksToBounds = true
        avatar.layer.cornerRadius = 21
        avatar.layer.borderColor = UIColor(red: 92, green: 103, blue: 116).cgColor
        avatar.layer.borderWidth = 0.5
    }
    
    func odd() {
        let bgColor = UIColor(red: 58, green: 61, blue: 66)
        backgroundColor = bgColor
        contentView.backgroundColor = bgColor
    }
    
    func even() {
        let bgColor = UIColor(red: 62, green: 65, blue: 70)
        backgroundColor = bgColor
        contentView.backgroundColor = bgColor
    }

    // MARK: - base
    
    func setup(for model: ReviewViewModel) {
        
        avatar.sd_progressive_setImage(with: URL(string: model.creator.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
        name.text = model.creator.name
        note.text = model.comment
    }
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ProfilePastTimeCell.height)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return true
    }
    
}
