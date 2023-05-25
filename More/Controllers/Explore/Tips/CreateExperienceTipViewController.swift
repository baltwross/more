//
//  CreateExperienceTipViewController.swift
//  More
//
//  Created by Luko Gjenero on 18/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class CreateExperienceTipViewController: UIViewController, UITextViewDelegate {

    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var textView: AutoGrowingTextView!
    
    var cancel: (()->())?
    var done: ((_ text: String)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.isEnabled = false
        
        textView.placeholderLabel.text = "What's useful to know about this experience? People talk about insider locations, useful things to know, etc."
        textView.placeholderLabel.font = textView.font
        textView.placeholderLabel.textColor = .lightPeriwinkle
        
        textView.delegate = self
    }
    
    @IBAction private func cancelTouch(_ sender: Any) {
        cancel?()
    }
    
    @IBAction private func doneTouch(_ sender: Any) {
        done?(textView.text)
    }

    func textViewDidChange(_ textView: UITextView) {
        doneButton.isEnabled = !textView.text.isEmpty
    }
    
}
