//
//  ReviewUserHeaderTop.swift
//  More
//
//  Created by Luko Gjenero on 23/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
class ReviewUserHeaderTop: LoadableView {

    static let height: CGFloat = 134
    
    @IBOutlet private weak var oval: UIView!
    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var step: UILabel!
    
    var avatarTap: (()->())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        oval.layer.cornerRadius = oval.frame.width * 0.5
    }
    
    func setup(for user: ShortUser) {
        avatar.sd_progressive_setImage(with: URL(string: user.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
    }
    
    func setupStep(_ step: Int, of stepNum: Int) {
        self.step.text = "\(step)/\(stepNum)"
    }
    
    func setupThanks() {
        self.step.text = "Thanks"
    }
    
    @IBAction func avatarTouch(_ sender: Any) {
        avatarTap?()
    }
}
