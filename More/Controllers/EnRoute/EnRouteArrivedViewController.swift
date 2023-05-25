//
//  EnRouteArrivedViewController.swift
//  More
//
//  Created by Luko Gjenero on 25/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EnRouteArrivedViewController: UIViewController {

    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backgroundButton: UIButton!
    
    var reportTap: (()->())?
    var doneTap: (()->())?
    var backTap: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func reportTouch(_ sender: Any) {
        reportTap?()
    }
    
    @IBAction func backTouch(_ sender: Any) {
        exitFromBelow { [weak self] in
            self?.backTap?()
        }
    }
    
    func setup(for time: Time, met: Bool = true) {
        if met {
            titleLabel.text = "Did you find each other?"
            subtitleLabel.text = "Please confirm if you and \(time.otherPerson().name) have met."
            reportButton.isHidden = true
        } else {
            titleLabel.text = "Did you arrive?"
            subtitleLabel.text = "Please confirm that you arrived at the meeting point."
            reportButton.isHidden = true
        }
    }

}
