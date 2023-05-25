//
//  ExploreEmptyView.swift
//  More
//
//  Created by Luko Gjenero on 14/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ExploreEmptyView: LoadableView {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var subtitle: UILabel!
    
    func setupForDesignedExperiences() {
        title.text = "You have not created an experience yet"
        subtitle.text = "Use the Experience designer and create your perfect experience."
    }
    
    func setupForPastExperiences() {
        title.text = "You have not been on a time yet"
        subtitle.text = "Try to find an experience you would like to live through or create your own and see who joins."
    }
    
}
