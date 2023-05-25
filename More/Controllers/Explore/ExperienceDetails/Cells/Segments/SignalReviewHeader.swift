//
//  SignalReviewHeader.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class SignalReviewHeader: LoadableView {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var quote: UILabel!
    
    var readMoreTap: (()->())?
    
    func setup(for model: ReviewViewModel) {
        
        let df = DateFormatter()
        df.dateFormat = "MMMM d, h:mma"
        date.text = df.string(from: model.time.createdAt).uppercased()
        quote.text = model.time.signal.text
    }
    
    @IBAction private func readMoreTouch(_ sender: Any) {
        readMoreTap?()
    }
    
    private func setupNote(_ text: String) {
        quote.text = text
    }
    
    class func size(for model: ReviewViewModel, in size: CGSize) -> CGSize {
        let font = UIFont(name: "Avenir-Heavy", size: 14) ?? UIFont.systemFont(ofSize: 14)
        var noteHeight = model.time.signal.text.height(withConstrainedWidth: size.width, font: font)
        noteHeight += 1
        return CGSize(width: size.width, height: 22 + noteHeight)
    }

}
