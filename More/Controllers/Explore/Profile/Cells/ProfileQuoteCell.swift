//
//  ProfileQuoteCell.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileQuoteCell: ProfileBaseCell {
    
    @IBOutlet private weak var quote: UILabel!
    @IBOutlet private weak var author: UILabel!
    
    // MARK: - base
    
    override func setup(for model: UserViewModel) {
        
        quote.text = model.quote
        author.text = model.quoteAuthor
    }
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        
        let quoteFont = UIFont(name: "Avenir-Heavy", size: 13) ?? UIFont.systemFont(ofSize: 13)
        let authorFont = UIFont(name: "Gotham-Medium", size: 9) ?? UIFont.systemFont(ofSize: 9)
        
        let quoteHeight = model.quote.height(withConstrainedWidth: size.width - 74, font: quoteFont) + 1
        let authorHeight = model.quoteAuthor.height(withConstrainedWidth: CGFloat.greatestFiniteMagnitude, font: authorFont) + 1
        
        return CGSize(width: size.width, height: 32 + quoteHeight + 8 + authorHeight + 18)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return model.quote.count > 0
    }
    
}
