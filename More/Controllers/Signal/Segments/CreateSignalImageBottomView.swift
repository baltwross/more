//
//  CreateSignalImageBottomView.swift
//  More
//
//  Created by Luko Gjenero on 26/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CreateSignalImageBottomView: LoadableView {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var photosButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    var nextTap: (()->())?
    var searchTap: (()->())?
    var photosTap: (()->())?
    var cameraTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        enableShadow(color: .black)
        
        let buttons = [searchButton, photosButton, cameraButton]
        for button in buttons {
            button?.layer.cornerRadius = 37.5
            button?.layer.masksToBounds = true
            button?.layer.borderColor = Colors.selectImageButtonBorder.cgColor
            button?.layer.borderWidth = 2
        }
        setDark(false)
    }
    
    @IBAction func nextTouch(_ sender: Any) {
        nextTap?()
    }
    
    @IBAction func searchTouch(_ sender: Any) {
        searchTap?()
    }
    
    @IBAction func photosTouch(_ sender: Any) {
        photosTap?()
    }
    
    @IBAction func cameraTouch(_ sender: Any) {
        cameraTap?()
    }
    
    func setDark(_ dark: Bool) {
        if dark {
            nextButton.isUserInteractionEnabled = true
            nextButton.backgroundColor = Colors.previewDarkBackground
            nextButton.setTitleColor(Colors.previewDarkText, for: .normal)
        } else {
            nextButton.isUserInteractionEnabled = false
            nextButton.backgroundColor = Colors.previewLightBackground
            nextButton.setTitleColor(Colors.previewLightText, for: .normal)
        }
    }
}
