//
//  ChatViewVideoPrepView.swift
//  More
//
//  Created by Luko Gjenero on 18/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ChatViewVideoPrepView: LoadableView {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var time: CountdownLabel!

    override func setupNib() {
        super.setupNib()
        time.setDateFormat("s")
    }
    
    func countdown(from seconds: Int) {
        time.countdown(to: Date(timeIntervalSinceNow: TimeInterval(seconds) + 0.5))
    }
}
