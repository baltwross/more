//
//  EditProfileQuoteView.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class EditProfileQuoteView: LoadableView {

    @IBOutlet private weak var quoteLabel: UILabel!
    @IBOutlet private weak var quoteAuthorLabel: UILabel!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    
    var searchTap: (()->())?
    var editTap: (()->())?
    
    @IBAction func searchTouch(_ sender: Any) {
        searchTap?()
    }
    
    @IBAction func editTouch(_ sender: Any) {
        editTap?()
    }
    
    func setup(quote: String, quoteAuthor: String) {
        if quote.count > 0 {
            quoteLabel.alpha = 1
            quoteLabel.text = quote
            quoteAuthorLabel.text = quoteAuthor
        } else {
            quoteLabel.alpha = 0.5
            quoteLabel.text = "Find a quote that describes you ..."
            quoteAuthorLabel.text = ""
        }
    }
}
