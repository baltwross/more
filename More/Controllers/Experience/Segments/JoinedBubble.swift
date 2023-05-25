//
//  JoinedBubble.swift
//  More
//
//  Created by Luko Gjenero on 07/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class JoinedBubble: LoadableView {
    
    @IBOutlet private weak var blur: UIVisualEffectView!
    @IBOutlet private weak var title: UILabel!
    
    override func setupNib() {
        super.setupNib()
        
        blur.layer.cornerRadius = 45
        blur.layer.masksToBounds = true
    }
    
    func setup(for experience: Experience) {
        setupTitle(experience.title)
    }
    
    private func setupTitle(_ name: String) {
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Avenir-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        var part = NSAttributedString(
            string: "You’ve successfully requested to join ",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.blueGrey,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        font = UIFont(name: "Gotham-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        part = NSAttributedString(
            string: name + ".",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.charcoalGrey,
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        title.attributedText = text
    }
    
}
