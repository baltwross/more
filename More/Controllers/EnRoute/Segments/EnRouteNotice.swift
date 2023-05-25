//
//  EnRouteNotice.swift
//  More
//
//  Created by Luko Gjenero on 19/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EnRouteNotice: LoadableView {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var text: SpecialLabel!
    
    func setup(title: String, text: String) {
        self.title.text = title
        self.text.text = text
    }

}
