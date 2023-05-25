//
//  RequestEmptyView.swift
//  More
//
//  Created by Luko Gjenero on 11/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class RequestEmptyView: LoadableView {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var expandedView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var collapsedView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editLabel: UILabel!
    
    var skipTap: (()->())?
    
    var editTap: (()->())?
    
    var isExpanded: Bool = true {
        didSet {
            skipButton.isHidden = !isExpanded
            expandedView.isHidden = !isExpanded
            collapsedView.isHidden = isExpanded
        }
    }
    
    @IBAction func skipTouch(_ sender: Any) {
        skipTap?()
    }
    
    @IBAction func editTouch(_ sender: Any) {
        editTap?()
    }
    
    func setup(for user: UserViewModel) {
        subtitle.text = "Sharing why you're excited to do this makes it more likely that \(user.name) will accept."
    }
    
    func setup(for user: ShortUser) {
        subtitle.text = "Sharing why you're excited to do this makes it more likely that \(user.name) will accept."
    }
    
}
