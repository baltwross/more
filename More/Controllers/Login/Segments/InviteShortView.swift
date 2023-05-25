//
//  InviteShortView.swift
//  More
//
//  Created by Luko Gjenero on 18/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class InviteShortView: LoadableView {

    @IBOutlet private weak var rejectButton: UIButton!
    @IBOutlet private weak var acceptButton: UIButton!
    
    var onAccept: (() -> Void)? = nil
    var onReject: (() -> Void)? = nil
    
    override func setupNib() {
        super.setupNib()
        
        rejectButton.layer.cornerRadius = 26.5
        rejectButton.layer.borderColor = UIColor(red: 244, green: 244, blue: 244).cgColor
        rejectButton.layer.borderWidth = 1
        
        acceptButton.layer.cornerRadius = 26.5
    }
    
    @IBAction private func onAcceptClicked(_ sender: UIButton) {
        onAccept?()
    }
    
    @IBAction private func onRejectClicked(_ sender: UIButton) {
        onReject?()
    }

}
