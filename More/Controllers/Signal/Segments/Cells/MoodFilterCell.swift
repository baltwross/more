//
//  MoodFilterCell.swift
//  More
//
//  Created by Luko Gjenero on 03/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class MoodFilterCell: MoodCell {
    
    @IBOutlet private weak var bubble: RoundedMoodBubble!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        image.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    override func setup(for type: SignalType, selected: Bool) {
        
        label.text = type.rawValue.uppercased()
        
        if selected {
            label.textColor = UIColor.white
            bubble.color = UIColor(red: 12, green: 12, blue: 12)
            
            image.isHidden = false
            image.image = SignalType.image(for: type)
            
        } else {
            label.textColor = UIColor(red: 40, green: 40, blue: 43)
            bubble.color = UIColor.white

            image.isHidden = false
            image.image = SignalType.grayscaleImage(for: type)
        }
    }
    
}



