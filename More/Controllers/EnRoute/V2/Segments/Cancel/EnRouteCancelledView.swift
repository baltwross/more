//
//  EnRouteCancelledView.swift
//  More
//
//  Created by Luko Gjenero on 10/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class EnRouteCancelledView: LoadableView {

    enum Option {
        case cancel, issue, unsafe
    }
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subTitle: UILabel!
    @IBOutlet private weak var button: BottomButton!
    
    var option: Option = .cancel {
        didSet {
            updateOption()
        }
    }
    
    var tap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        button.tap = { [weak self] in
            self?.tap?()
        }
        
        updateOption()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 12.0, height: 12.0))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    private func updateOption() {
        button.type = .dark
        switch option {
        case .cancel:
            title.text = "Time Cancelled"
            subTitle.text = "Your Time has been cancelled. Next time, please don't Request or Accept Times if you're unsure."
            button.setTitle("KEEP EXPLORING")
        case .issue:
            title.text = "Time Cancelled"
            subTitle.text = "Your Time has been cancelled. Please let us know your issue so we can investigate."
            button.setTitle("REPORT ISSUE")
        case .unsafe:
            button.type = .red
            title.text = "Time Cancelled"
            subTitle.text = "Your Time has been cancelled. If this is an emergency, please dial 911 immediately."
            button.setTitle("DIAL 911")
        }
    }
}
