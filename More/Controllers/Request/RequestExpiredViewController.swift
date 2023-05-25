//
//  RequestExpiredViewController.swift
//  More
//
//  Created by Luko Gjenero on 04/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class RequestExpiredViewController: UIViewController {

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
    
    func setupForRequest(cancelled: Bool) {
        if cancelled {
            titleLabel.text = "Request was withdrawn"
            subtitleLabel.text = "Unfortunately the request has withdrawn."
        } else {
            let minutes = Int(round(ConfigService.shared.signalRequestExpiration / 60))
            titleLabel.text = "Request expired"
            subtitleLabel.text = "Request has expired. You have \(minutes) minutes to accept a request. Be faster next time."
        }
    }
    
    func setupForSignal(cancelled: Bool) {
        if cancelled {
            titleLabel.text = "Signal was withdrawn"
            subtitleLabel.text = "Unfortunately the signal has withdrawn."
        } else {
            titleLabel.text = "Signal expired"
            subtitleLabel.text = "Signal has expired. Better luck next time."
        }
    }

}
