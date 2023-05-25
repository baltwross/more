//
//  CreateSignalQuoteCell.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let quotePlaceholder = "Dream up what you wanna do ..."

class CreateSignalQuoteCell: CreateSignalBaseCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet private weak var placeholder: UILabel!
    private let toolbar = CreateSignalQuoteToolbar()
    
    var doneTap: ((_ text: String?)->())?
    var textUpdated: ((_ text: String?)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.contentInset = .zero
        textView.contentInsetAdjustmentBehavior = .never
        textView.contentInset = .zero
        textView.delegate = self
        
        placeholder.font = textView.font
        placeholder.textColor = Colors.quoteInputPlaceholder
        placeholder.text = quotePlaceholder
        placeholder.numberOfLines = 0
        
        toolbar.frame = CGRect(x: 0, y: 0, width: 320, height: 110)
        textView.inputAccessoryView = toolbar
        toolbar.doneTap = { [weak self] in
            self?.doneTap?(self?.textView.text)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: textView)
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func doneTouch(_ sender: Any) {
        doneTap?(textView.text)
    }
    
    func showKeyboard() {
        textView.becomeFirstResponder()
    }
    
    func hideKeyboard() {
        textView.resignFirstResponder()
    }
    
    // MARK: - base
    
    override class func size(for model: CreateExperienceViewModel, in size: CGSize, keyboardVisible: Bool) -> CGSize {
        
        let quoteFont = UIFont(name: "Avenir-Black", size: 21) ?? UIFont.systemFont(ofSize: 21)
        var quoteText = model.text
        if model.text.count == 0 {
            quoteText = quotePlaceholder
        }
        var height = quoteText.height(withConstrainedWidth: size.width - 50, font: quoteFont)
        height = max(44, height)
        height += 24
        
        if keyboardVisible {
            height = size.height
        }
        
        return CGSize(width: size.width, height: height)
    }
    
    override class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        return true
    }
    
    override func setup(for model: CreateExperienceViewModel, keyboardVisible: Bool) {
        textView.text = model.text
        textChanged()
    }
    
    // MARK: - input
    
    @objc private func textChanged() {
        let textLength = textView.text?.count ?? 0
        placeholder.isHidden = textLength > 0
        toolbar.setup(for: 500 - textLength, enabled: true)
        textUpdated?(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
        if text.contains("\n") {
            doneTap?(textView.text)
            return false
        }
        
        if let currentText = textView.text,
            let textRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: textRange, with: text)
            
            if updatedText.count > 500 {
                return false
            }
        }
        return true
    }
}
