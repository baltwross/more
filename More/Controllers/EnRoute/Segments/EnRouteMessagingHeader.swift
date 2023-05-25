//
//  EnRouteMessagingHeader.swift
//  More
//
//  Created by Luko Gjenero on 14/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EnRouteMessagingHeader: LoadableView {

    @IBOutlet private weak var downButton: UIButton!
    @IBOutlet private weak var fade: FadeView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var divider: UIView!
    
    var downTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        fade.orientation = .up
        fade.color = backgroundColor ?? .clear
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            fade?.color = backgroundColor ?? .clear
        }
    }
    
    func setup(for time: ExperienceTime) {
        titleLabel.text = time.post.experience.text
    }
    
    func setupFull() {
        titleLabel.isHidden = false
        fade.backgroundColor = fade.color
        divider.isHidden = false
    }
    
    func setupHalf() {
        titleLabel.isHidden = true
        fade.backgroundColor = .clear
        divider.isHidden = true
    }
    
    @IBAction func downTouch(_ sender: Any) {
        downTap?()
    }

}
