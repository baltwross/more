//
//  ReviewBottomBar.swift
//  More
//
//  Created by Luko Gjenero on 23/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ReviewBottomBar: LoadableView {

    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var nextButton: FancyNextButton!
    @IBOutlet private weak var submit: UIButton!
    
    var backTap: (()->())?
    var nextTap: (()->())?
    var submitTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        nextButton.enableWithAnimation(true, false)
        
        submit.layer.cornerRadius = 26.5
        submit.layer.masksToBounds = true
        submit.setBackgroundImage(UIImage.onePixelImage(color: UIColor(red: 40, green: 40, blue: 43)), for: .normal)
        submit.setBackgroundImage(UIImage.onePixelImage(color: UIColor(red: 218, green: 221, blue: 226)), for: .disabled)
        
        setupForBack()
    }
    
    @IBAction private func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction private func nextTouch(_ sender: Any) {
        nextTap?()
    }
    
    @IBAction private func submitTouch(_ sender: Any) {
        submitTap?()
    }
    
    func setupForNone() {
        back.isHidden = true
        nextButton.isHidden = true
        submit.isHidden = true
    }
    
    func setupForNext() {
        back.isHidden = true
        nextButton.isHidden = false
        submit.isHidden = true
    }
    
    func setupForBack() {
        back.setTitle("BACK", for: .normal)
        back.isHidden = false
        nextButton.isHidden = true
        submit.isHidden = true
    }
    
    func setupForBackAndNext(loading: Bool = false) {
        back.setTitle("BACK", for: .normal)
        back.isHidden = false
        nextButton.isHidden = false
        submit.isHidden = true
        if loading {
            nextButton.enableWithAnimation(false, true)
        } else {
            nextButton.enableWithAnimation(true, false)
        }
    }
    
    func setupForBackAndSubmit(_ enableSubmit: Bool) {
        back.setTitle("BACK", for: .normal)
        back.isHidden = false
        nextButton.isHidden = true
        submit.isHidden = false
        submit.isEnabled = enableSubmit
    }
    
    func setupForDismiss() {
        back.setTitle("DISMISS", for: .normal)
        back.isHidden = false
        nextButton.isHidden = true
        submit.isHidden = true
    }
    
}
