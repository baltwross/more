//
//  CreateSignalMoodViewController.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let cellIdentifier = "Cell"

class CreateSignalMoodViewController: UIViewController {

    @IBOutlet private weak var topBar: CreateSignalMoodTopBar!
    @IBOutlet private weak var selector: CreateSignalMoodSelectorView!

    var back: ((_ type: SignalType?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBar.backTap = { [weak self] in
            self?.back?(self?.selector?.selected.first)
        }
        
        selector.selectionChanged = { [weak self] selection in
            if let first = self?.selector?.selected.first {
                let impact = UIImpactFeedbackGenerator()
                impact.impactOccurred()
                self?.back?(first)
            }
        }
    }
    
    func setup(type: SignalType) {
        selector.selected = [type]
    }
}
