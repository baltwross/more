//
//  EditProfilePhotosCollectionViewCell.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

class EditProfilePhotosCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var imageView: BorderedImageView!
    
    var editTap: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editButton.enableShadow(color: .black, path: UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 30, height: 30)).cgPath)
    }
    
    @IBAction func editTouch(_ sender: Any) {
        editTap?()
    }
    
    func setup(for url: String) {
        editButton.isHidden = false
        imageView.contentMode = .scaleAspectFill
        imageView.sd_progressive_setImage(with: URL(string: url), placeholderImage: UIImage.profileThumbPlaceholder())
    }
    
    func setupForAdd() {
        editButton.isHidden = true
        imageView.sd_cancelCurrentImageLoad_progressive()
        imageView.contentMode = .center
        imageView.image = UIImage(named: "camera_gray_big")
    }

}
