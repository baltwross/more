//
//  LoginMemoriesViewController.swift
//  More
//
//  Created by Luko Gjenero on 30/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class LoginMemoriesViewController: BaseLoginViewController {
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var memories: AutoGrowingTextView!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var headerTop: NSLayoutConstraint!
    @IBOutlet private weak var header: UIView!
    @IBOutlet private weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController?.viewControllers.count == 0 {
            backButton.isHidden = true
        }
        
        memories.placeholderLabel.font = memories.font
        memories.placeholderLabel.text = "One of my best memories..."
        memories.placeholderLabel.textColor = Colors.quoteInputPlaceholder
        
        let toolbar = KeyboardManager.createToolbar()
        toolbar.addTarget(self, action: #selector(doneTouch), for: .touchUpInside)
        memories.inputAccessoryView = toolbar
        
        updateSubmitButton(dark: false)
        
        for constraint in view.constraints {
            if constraint.firstAnchor == container.bottomAnchor ||
                constraint.secondAnchor == container.bottomAnchor {
                bottomContraint = constraint
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(check), name: UITextView.textDidChangeNotification, object: memories)
        trackKeyboardAndPushUp()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func backTouch(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitTouch(_ sender: Any) {
        if let memories = memories.text, memories.count > 0 {
            
            ProfileService.shared.updateMemories(memories)
            nextView?()
        }
    }
    
    @objc private func keyboardUp() {
        moveTop(up: true)
    }
    
    @objc private func keyboardDown() {
        moveTop(up: false)
    }
    
    private func moveTop(up: Bool) {
        headerTop.constant = up ? -header.frame.height : 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.header.layoutIfNeeded()
            self?.header.alpha = up ? 0 : 1
        }
    }
    
    @objc private func check() {
        if let memories = memories.text, memories.count > 0 {
            updateSubmitButton(dark: true)
        } else {
            updateSubmitButton(dark: false)
        }
    }
    
    @objc private func doneTouch() {
        memories.resignFirstResponder()
        check()
    }
    
    private func updateSubmitButton(dark: Bool) {
        if dark {
            submitButton.backgroundColor = Colors.previewDarkBackground
            submitButton.setTitleColor(Colors.previewDarkText, for: .normal)
        } else {
            submitButton.backgroundColor = Colors.previewLightBackground
            submitButton.setTitleColor(Colors.previewLightText, for: .normal)
        }
    }

}
