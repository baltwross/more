//
//  ReviewCommentView.swift
//  More
//
//  Created by Luko Gjenero on 24/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewCommentView: LoadableView, UITextViewDelegate {

    @IBOutlet private weak var bubbleView: UIView!
    @IBOutlet private weak var commentView: UITextViewNoPadding!
    @IBOutlet private weak var charView: SpecialLabel!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var placeholderTitle: UILabel!
    @IBOutlet private weak var placeholderSubtitle: UILabel!
    
    var textChanged: ((_ text: String?)->())?
    
    override func setupNib() {
        super.setupNib()
        bubbleView.layer.cornerRadius = 13
        bubbleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bubbleTap(sender:))))
        setupForPlaceholder()
        
        let done = KeyboardManager.createToolbar()
        done.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        commentView.inputAccessoryView = done
        commentView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func bubbleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if sender.view == bubbleView {
                setupForComment()
                commentView.becomeFirstResponder()
            }
        }
    }

    func setup(for model: CreateReviewModel) {
        
        placeholderSubtitle.text = "Share what you thought about your Time to help others understand what they can expect when they spend Time with \(model.time.otherPerson().name)."
        
        if let comment = model.comment, comment.count > 0 {
            commentView.text = comment
            updateCharCount()
            setupForComment()
        } else {
            setupForPlaceholder()
        }
    }
    
    private func setupForPlaceholder() {
        placeholderTitle.isHidden = false
        placeholderSubtitle.isHidden = false
        
        commentView.isHidden = true
        editButton.isHidden = true
        charView.isHidden = true
    }
    
    private func setupForComment() {
        placeholderTitle.isHidden = true
        placeholderSubtitle.isHidden = true
        
        commentView.isHidden = false
        editButton.isHidden = false
        charView.isHidden = true
    }
    
    @objc private func closeKeyboard() {
        commentView.resignFirstResponder()
    }
    
    private func updateCharCount() {
        let charCount = commentView.text?.count ?? 0
        charView.text = "\(500 - charCount)"
        textChanged?(commentView.text)
    }
    
    @objc private func keyboardUp() {
        editButton.isHidden = true
        charView.isHidden = false
    }
    
    @objc private func keyboardDown() {
        if let comment = commentView.text, comment.count > 0 {
            setupForComment()
        } else {
            setupForPlaceholder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let oldText = textView.text {
            let newText = oldText.replacingCharacters(in: Range(range, in: oldText)!, with: text)
            if newText.count > 500 {
                return false
            }
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateCharCount()
    }
    
}
