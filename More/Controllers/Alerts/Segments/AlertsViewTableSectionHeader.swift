//
//  AlertsViewTableSectionHeader.swift
//  More
//
//  Created by Luko Gjenero on 18/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class AlertsViewTableSectionHeader: LoadableView {

    @IBOutlet private weak var label: UILabel!
    
    func setup(for text: String) {
        label.text = text
    }
}
