//
//  SpecialLabel.swift
//  More
//
//  Created by Luko Gjenero on 01/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class SpecialLabel: UILabel {

    @IBInspectable public var kern: CGFloat = 0 {
        didSet {
            updateText()
        }
    }
    
    @IBInspectable public var underline: NSUnderlineStyle = [] {
        didSet {
            updateText()
        }
    }
    
    @IBInspectable public var specialLineSpacing: CGFloat = 0 {
        didSet {
            updateText()
        }
    }
    
    /// lineHight will be used if defined (> 0) and lineSpacing will be ignored
    @IBInspectable public var specialLineHeight: CGFloat = 0 {
        didSet {
            updateText()
        }
    }
    
    private func updateText() {
        var text = super.text
        if text == nil {
            text = super.attributedText?.string
        }
        updateText(to: text)
    }
    
    private func updateText(to text: String?) {
        
        guard let text = text else {
            super.text = nil
            super.attributedText = nil
            return
        }
        
        if kern > 0 || !underline.isEmpty || specialLineSpacing > 0 || specialLineHeight > 0 {
            let attributedText = NSMutableAttributedString(string: text)
            
            if kern > 0 {
                attributedText.addAttribute(.kern, value: kern, range: NSRange(location: 0, length: attributedText.length))
            }
            if !underline.isEmpty {
                attributedText.addAttribute(.underlineStyle, value: underline.rawValue, range: NSRange(location: 0, length: attributedText.length))
            }
            
            var lineSpacing = specialLineSpacing
            var lineHight = font.pointSize * lineSpacing
            if specialLineHeight > 0 {
                lineSpacing = specialLineHeight / font.lineHeight
                lineHight = specialLineHeight
            }
            
            if lineSpacing > 0 {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = lineSpacing
                paragraphStyle.lineHeightMultiple = lineSpacing
                paragraphStyle.maximumLineHeight = lineHight
                paragraphStyle.alignment = textAlignment
                attributedText.addAttribute(.paragraphStyle, value:paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
            }

            super.text = nil
            super.attributedText = attributedText
        } else {
            super.attributedText = nil
            super.text = text
        }
    }
    
    override var text: String? {
        get {
            return super.text
        }
        set {
            updateText(to: newValue)
        }
    }
    
    override var font: UIFont! {
        didSet {
            updateText()
        }
    }
}
