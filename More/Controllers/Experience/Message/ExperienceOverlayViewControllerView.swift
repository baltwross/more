//
//  ExperienceOverlayViewControllerView.swift
//  More
//
//  Created by Luko Gjenero on 04/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceOverlayViewControllerView : UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit == self {
            return nil
        }
        return hit
    }
    
}
