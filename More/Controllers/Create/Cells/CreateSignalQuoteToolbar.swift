//
//  CreateSignalQuoteToolbar.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalQuoteToolbar: LoadableView {

    @IBOutlet private weak var characterCount: UILabel!
    @IBOutlet private weak var doneButton: UIButton!
    
    var doneTap: (()->())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        doneButton.layoutIfNeeded()
        doneButton.enableShadow(color: .black, path: UIBezierPath(rect: doneButton.bounds).cgPath)
    }
    
    func setup(for characterCount: Int, enabled: Bool) {
        self.characterCount.text = "\(characterCount)"
        self.doneButton.isUserInteractionEnabled = enabled
    }
    
    @IBAction func doneTouch(_ sender: Any) {
        doneTap?()
    }
}
