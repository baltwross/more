//
//  CancelOptionsView.swift
//  More
//
//  Created by Luko Gjenero on 09/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CancelOptionsView: LoadableView {
    
    enum Option {
        case cancel, issue, unsafe
    }
    
    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var cancel: EnRouteCancelOption!
    @IBOutlet private weak var issue: EnRouteCancelOption!
    @IBOutlet private weak var unsafe: EnRouteCancelOption!
    
    var backTap: (()->())?
    var cancelTap: (()->())?
    var issueTap: (()->())?
    var unsafeTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        cancel.option = .cancel
        issue.option = .issue
        unsafe.option = .unsafe
        
        cancel.tap = { [weak self] in
            self?.cancelTap?()
        }
        issue.tap = { [weak self] in
            self?.issueTap?()
        }
        unsafe.tap = { [weak self] in
            self?.unsafeTap?()
        }
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
    
    @IBAction private func backTouch(_ sender: Any) {
        backTap?()
    }
    
}
