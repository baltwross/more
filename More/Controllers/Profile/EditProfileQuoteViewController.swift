//
//  EditProfileQuoteViewController.swift
//  More
//
//  Created by Luko Gjenero on 16/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EditProfileQuoteViewController: UIViewController {

    private enum State {
        case quote, source
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var quoteView: AutoGrowingTextView!
    @IBOutlet weak var quoteUnderline: UIView!
    
    private var state: State = .quote
    private var quote: String? = nil
    private var author: String? = nil
    
    var closeTap: ((_ quote: String?, _ author: String?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        quoteUnderline.alpha = 0.4
        
        let done = KeyboardManager.createToolbar()
        done.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        
        quoteView.inputAccessoryView = done
        
        quoteView.placeholderLabel.font = quoteView.font
        quoteView.placeholderLabel.textColor = quoteView.textColor?.withAlphaComponent(0.4)
        quoteView.placeholderLabel.text = "A quote that resonates with me..."
        
        NotificationCenter.default.addObserver(self, selector: #selector(startedEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endedEditing(_:)), name: UITextView.textDidEndEditingNotification, object: nil)
        
        for constraint in view.constraints {
            if constraint.firstAnchor == contentView.bottomAnchor ||
                constraint.secondAnchor == contentView.bottomAnchor {
                bottomContraint = constraint
                break
            }
        }
        trackKeyboardAndPushUp()
    }
    
    @IBAction func closeKeyboard() {
        quoteView.resignFirstResponder()
        nextState()
    }
    
    @IBAction func closeTouch(_ sender: Any) {
        quoteView.resignFirstResponder()
        closeTap?(nil, nil)
    }
    
    @objc private func startedEditing(_ notice: Notification) {
        if notice.object as? UITextView == quoteView {
            quoteUnderline.alpha = 1
            quoteView.maxHeightConstraint?.constant = contentView.frame.height - 52
            quoteView.text = quoteView.text
        }
    }
    
    @objc private func endedEditing(_ notice: Notification) {
        if notice.object as? UITextView == quoteView {
            quoteUnderline.alpha = 0.4
            quoteView.maxHeightConstraint?.constant = contentView.frame.height - 52
            quoteView.text = quoteView.text
        }
    }
    
    func setup(for profile: Profile) {
        quoteView.text = profile.quote
        author = profile.quoteAuthor
    }
    
    private func nextState() {
        switch state {
        case .quote:
            state = .source
            quote = quoteView.text
            quoteView.text = author
            quoteView.placeholderLabel.text = "Source (Optional)"
        case .source:
            closeTap?(quote, quoteView.text)
        }
    }

}
