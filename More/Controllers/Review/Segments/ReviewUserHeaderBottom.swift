//
//  ReviewUserHeaderBottom.swift
//  More
//
//  Created by Luko Gjenero on 23/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ReviewUserHeaderBottom: LoadableView {

    static let height: CGFloat = 60
    
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var submit: UILabel!
    
    var tap: (()->())?
    
    func setup(for time: Time) {
        setupName(for: time)
        setupDate(for: time)
        submit.isHidden = true
    }
    
    func setupForSubmitted() {
        name.isHidden = true
        date.isHidden = true
        submit.isHidden = false
    }
    
    private func setupName(for time: Time) {
        let text = NSMutableAttributedString()
        
        var font = UIFont(name: "Avenir-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        var part = NSAttributedString(
            string: "Time with ",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 124, green: 139, blue: 155),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        font = UIFont(name: "Avenir-Heavy", size: 14) ?? UIFont.systemFont(ofSize: 14)
        part = NSAttributedString(
            string: time.otherPerson().name,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 67, green: 74, blue: 81),
                         NSAttributedString.Key.font : font])
        text.append(part)
        
        name.attributedText = text
    }
    
    private func setupDate(for time: Time) {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, h:mma"
        date.text = df.string(from: time.endedAt ?? Date()).uppercased()
    }

    @IBAction private func touch(_ sender: Any) {
        tap?()
    }
}
