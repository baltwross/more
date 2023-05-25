//
//  EditProfilePhotosView.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EditProfilePhotosView: LoadableView {

    @IBOutlet weak var maskingView: UIView!
    @IBOutlet private weak var photosView: EditProfilePhotosCollectionView!
    @IBOutlet weak var dragLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addLabel: UILabel!
    
    var addTap: (()->())?
    var editTap: ((_ url: Image)->())?
    var rearranged: ((_ urls: [Image])->())?
    
    override func setupNib() {
        super.setupNib()
        
        maskingView.layer.borderColor = UIColor.white.cgColor
        maskingView.layer.borderWidth = 2
        
        photosView.addTap = { [weak self] in
            self?.addTap?()
        }
        photosView.editTap = { [weak self] (image) in
            self?.editTap?(image)
        }
        photosView.rearranged = { [weak self] (images) in
            self?.rearranged?(images)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        maskingView.layer.cornerRadius = frame.width * 0.7
        maskingView.layer.masksToBounds = true
    }
    
    func setup(for  profile: Profile) {
        if let photos = profile.images, photos.count > 0 {
            addButton.isHidden = true
            addLabel.isHidden = true
            photosView.isHidden = false
            dragLabel.isHidden = false
            photosView.setup(for: photos)
        } else {
            addButton.isHidden = false
            addLabel.isHidden = false
            dragLabel.isHidden = true
            photosView.isHidden = true
            photosView.setup(for: [])
        }
    }

    @IBAction func addTouch(_ sender: Any) {
        addTap?()
    }
}
