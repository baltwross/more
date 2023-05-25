//
//  MessagingInputBar.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
class MessagingInputBar: LoadableView {

    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var camera: UIButton!
    @IBOutlet private weak var textContainer: UIView!
    @IBOutlet weak var textView: AutoGrowingTextView!
    @IBOutlet private weak var send: UIButton!
    
    var cameraTap: (()->())?
    var sendTap: ((_ text: String)->())?
    var isTypingChanged: (()->())?
    
    var showAvatar: Bool = false {
        didSet {
            avatar.isHidden = !showAvatar
            camera.isHidden = showAvatar
        }
    }

    var placeholder: String? {
        get {
            return textView.placeholderLabel.text
        }
        set {
            textView.placeholderLabel.text = newValue
        }
    }
    
    var isTyping: Bool = false
    
    override func setupNib() {
        super.setupNib()
        
        textContainer.layer.borderColor = UIColor(red: 244, green: 244, blue: 244).cgColor
        textContainer.layer.borderWidth = 2
        textContainer.layer.cornerRadius = 27
        textContainer.layer.masksToBounds = true
        
        textView.placeholderLabel.text = "Your Message"
        textView.placeholderLabel.font = textView.font
        textView.placeholderLabel.textColor = Colors.inputPlaceholder
        textView.textColor = Colors.inputText
        
        send.enableShadow(
            color: .black,
            path: UIBezierPath(ovalIn: send.bounds.insetBy(dx: 5, dy: 5)).cgPath)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textBeginEditing), name: UITextView.textDidBeginEditingNotification, object: textView)
        NotificationCenter.default.addObserver(self, selector: #selector(textEndEditing), name: UITextView.textDidEndEditingNotification, object: textView)
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: textView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup(for user: ShortUser) {
        avatar.sd_progressive_setImage(with: URL(string: user.avatar), placeholderImage: UIImage.profileThumbPlaceholder())
    }
    
    func showKeyboard() {
        textView.becomeFirstResponder()
    }
    
    func hideKeyboard() {
        textView.resignFirstResponder()
    }
    
    func setText(_ text: String) {
        textView.text = text
    }
    
    func reset() {
        textView.text = ""
        if isTyping {
            isTyping = false
            isTypingChanged?()
        }
    }
    
    @IBAction private func cameraTouch(_ sender: Any) {
        cameraTap?()
    }
    
    @IBAction private func sendTouch(_ sender: Any) {
        guard let text = textView.text, text.count > 0 else { return }
        sendTap?(text)
    }
    
    @objc private func textBeginEditing() {
        if let text = textView.text, text.count > 0 {
            isTyping = true
            isTypingChanged?()
        }
    }
    
    @objc private func textEndEditing() {
        isTyping = false
        isTypingChanged?()
    }
    
    @objc private func textChanged() {
        if let text = textView.text, text.count > 0 {
            if !isTyping {
                isTyping = true
                isTypingChanged?()
            }
        } else if isTyping {
            isTyping = false
            isTypingChanged?()
        }
    }
    
}
