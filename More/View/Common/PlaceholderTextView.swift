//
//  PlaceholderTextView.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class PlaceholderTextView: UITextViewNoPadding {

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(placeholder_textChanged), name: UITextView.textDidChangeNotification, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - text
    
    override var text: String! {
        didSet {
            self.placeholder_textChanged()
        }
    }
    
    @objc private func placeholder_textChanged() {
        self.placeholderLabel.isHidden = self.text.count > 0
    }
    
    // MARK: - placeholder
    
    private var internalPlaceholderLabel: UILabel?
    
    var placeholderLabel: UILabel {
        get {
            if let placeholder = internalPlaceholderLabel {
                return placeholder
            }
            
            let placeholder = createPlaceholder()
            placeholder.isHidden = self.text.count > 0
            internalPlaceholderLabel = placeholder
            return placeholder
        }
    }
    
    private func createPlaceholder() -> UILabel {
        let placeholder = UILabel()
        placeholder.textAlignment = .left
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.numberOfLines = 0
        addSubview(placeholder)
        placeholder.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        placeholder.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        placeholder.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        // placeholder.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        placeholder.backgroundColor = .clear
        placeholder.isUserInteractionEnabled = false
        placeholder.setNeedsLayout()
        return placeholder
    }

}
