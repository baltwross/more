//
//  CannotRequestViewController.swift
//  More
//
//  Created by Luko Gjenero on 01/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class CannotRequestViewController: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var doneTap: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        background.backgroundColor = UIColor(red: 254, green: 254, blue: 254)
        setupForEnterFromBelow()
    }
    
    private var isFirst = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        enterFromBelow()
    }
    
    @IBAction func doneTouch(_ sender: Any) {
        exitFromBelow { [weak self] in
            self?.doneTap?()
        }
    }
}
