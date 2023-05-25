//
//  SignalReviewBubble.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
class SignalReviewBubble: LoadableView {

    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var stars: StarsView!
    @IBOutlet private weak var note: UILabel!
    @IBOutlet private weak var readMore: UIButton!

    var readMoreTap: (()->())?
    
    var enableReadMore: Bool {
        get {
            return !readMore.isHidden
        }
        set {
            readMore.isHidden = !newValue
        }
    }
    
    override func setupNib() {
        super.setupNib()
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        avatar.layer.cornerRadius = 21
        avatar.layer.masksToBounds = true
        avatar.layer.borderColor = UIColor(red: 92, green: 103, blue: 116).cgColor
        avatar.layer.borderWidth = 0.5
    }
    
    func setup(for model: ReviewViewModel, comment: String? = nil) {
        
        avatar.sd_progressive_setImage(with: URL(string: model.creator.avatar), placeholderImage: UIImage.profileThumbPlaceholder(), options: .highPriority)
        name.text = model.creator.name
        
        let df = DateFormatter()
        df.dateFormat = "MMM YYYY"
        date.text = df.string(from: model.createdAt)
        stars.rate = CGFloat(model.rate)
        setupNote(comment ?? model.comment)
    }
    
    @IBAction private func readMoreTouch(_ sender: Any) {
        readMoreTap?()
    }
    
    private func setupNote(_ text: String) {
        note.text = text
    }
    
    class func size(for model: ReviewViewModel, in size: CGSize) -> CGSize {
        let font = UIFont(name: "Avenir-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13)
        let noteHeight = model.comment.height(withConstrainedWidth: size.width - 32, font: font) + 1
        return CGSize(width: size.width, height: 70 + noteHeight + 16)
    }
    
}
