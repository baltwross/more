//
//  ChatViewVideoControlsView.swift
//  More
//
//  Created by Luko Gjenero on 08/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ChatViewVideoControlsView: LoadableView {

    @IBOutlet private weak var micButton: UIButton!
    @IBOutlet private weak var micLabel: UILabel!
    @IBOutlet private weak var micBlur: UIVisualEffectView!
    
    @IBOutlet private weak var cameraButton: UIButton!
    @IBOutlet private weak var cameraLabel: UILabel!
    @IBOutlet private weak var cameraBlur: UIVisualEffectView!
    
    @IBOutlet private weak var flipButton: UIButton!
    @IBOutlet private weak var flipLabel: UILabel!
    @IBOutlet private weak var flipBlur: UIVisualEffectView!
    
    @IBOutlet private weak var callButton: UIButton!
    @IBOutlet private weak var callLabel: UILabel!
    
    var micTap: (()->())?
    var cameraTap: (()->())?
    var flipTap: (()->())?
    var callTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        let viewsToRound  = [micButton, micBlur, cameraButton, cameraBlur, flipButton, flipBlur, callButton]
        for view in viewsToRound {
            view?.layer.cornerRadius = 25
            view?.layer.masksToBounds = true
        }
        
        /*
        micButton.setBackgroundImage(UIImage.onePixelImage(color: .whiteThree), for: .selected)
        micButton.setBackgroundImage(UIImage.onePixelImage(color: .clear), for: .normal)
        
        cameraButton.setBackgroundImage(UIImage.onePixelImage(color: .whiteThree), for: .selected)
        cameraButton.setBackgroundImage(UIImage.onePixelImage(color: .clear), for: .normal)
        */
    }
    
    var micEnabled: Bool {
        get {
            return micButton.isSelected
        }
        set {
            micLabel.text = newValue ? "Mute" : "Unmute"
            micButton.isSelected = newValue
            micButton.backgroundColor = newValue ? UIColor.whiteThree.withAlphaComponent(0.9) : .clear
        }
    }
    
    var cameraEnabled: Bool {
        get {
            return cameraButton.isSelected
        }
        set {
            cameraLabel.text = newValue ? "Video" : "Video"
            cameraButton.isSelected = newValue
            cameraButton.backgroundColor = newValue ? UIColor.whiteThree.withAlphaComponent(0.9) : .clear
        }
    }
    
    // MARK: - button actions
    
    @IBAction private func micButtonTouch(_ sender: Any) {
        micTap?()
    }
    
    @IBAction private func cameraButtonTouch(_ sender: Any) {
        cameraTap?()
    }
    
    @IBAction private func flipButtonTouch(_ sender: Any) {
        flipTap?()
    }
    
    @IBAction private func callButtonTouch(_ sender: Any) {
        callTap?()
    }

}
