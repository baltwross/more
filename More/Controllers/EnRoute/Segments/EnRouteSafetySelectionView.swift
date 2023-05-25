//
//  EnRouteSafetySelectionView.swift
//  More
//
//  Created by Luko Gjenero on 29/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EnRouteSafetySelectionView: LoadableView {

    @IBOutlet private weak var cancel: EnRouteSafetyOptionView!
    @IBOutlet private weak var issue: EnRouteSafetyOptionView!
    @IBOutlet private weak var unsafe: EnRouteSafetyOptionView!
    
    var cancelTap: (()->())?
    var issueTap: (()->())?
    var unsafeTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        cancel.type = .cancel
        issue.type = .issue
        unsafe.type = .unsafe
        
        cancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTouch)))
        issue.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(issueTouch)))
        unsafe.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(unsafeTouch)))
    }
    
    @objc private func cancelTouch() {
        cancelTap?()
    }
    
    @objc private func issueTouch() {
        issueTap?()
    }
    
    @objc private func unsafeTouch() {
        unsafeTap?()
    }
    

}
