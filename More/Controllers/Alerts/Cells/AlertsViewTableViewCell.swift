//
//  AlertsViewTableViewCell.swift
//  More
//
//  Created by Luko Gjenero on 18/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

class AlertsViewTableViewCell: UITableViewCell {

    @IBOutlet private weak var content: AlertContentView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    func setupForRequest(_ request: Request, in signal: Signal) {
        content.setupForRequest(request, in: signal)
    }
    
    func setupForMessgae(_ message: Message, in signal: Signal) {
        content.setupForMessgae(message, in: signal)
    }
    
    func setupForMessgae(_ message: Message, in time: Time) {
        content.setupForMessgae(message, in: time)
    }
    
    func setupForReview(in time: Time) {
        content.setupForReview(in: time)
    }
    
    func setupForWelcomeVideo() {
        content.setupForWelcomeVideo()
    }
}
