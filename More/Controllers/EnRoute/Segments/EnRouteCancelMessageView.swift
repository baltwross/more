//
//  EnRouteCancelMessageView.swift
//  More
//
//  Created by Luko Gjenero on 29/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EnRouteCancelMessageView: LoadableView {

    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var tableView: MessagingTableView!
    @IBOutlet private weak var input: MessagingInputBar!
    @IBOutlet private weak var messagingViewHeight: NSLayoutConstraint!
    
    private var time: ExperienceTime?

    private var message: Message?
    
    var backTap: (()->())?
    var send: ((_ message: String)->())?
    
    override func setupNib() {
        super.setupNib()
        
        confirmButton.alpha = 0
        
        emptyView = EmptyView()
        
        input.sendTap = { [weak self] (text) in
            self?.sendMessage(text)
        }
        tableView.edit = { [weak self] (text) in
            self?.edit()
        }
        input.placeholder = "Say why you're canceling"
        
        tableView.timeFormat = "Confirm to deliver"
        tableView.isEditable = true
        
        messagingViewHeight.constant = 80
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func setup(for time: ExperienceTime) {
        self.time = time
        
        if let user = ProfileService.shared.profile?.shortUser {
            input.showAvatar = true
            input.setup(for: user)
        }
        
        if time.chat.memberIds.count > 2 {
            emptyView?.setup()
        } else {
            let myId = ProfileService.shared.profile?.id ?? "--"
            let otherId = time.chat.memberIds.first(where: { $0 != myId }) ?? "--"
            if let chat = ChatService.shared.getChat(for: otherId) {
                emptyView?.setup(for: chat.other())
            }
        }
    }
    
    func showKeyboard() {
        input.showKeyboard()
    }
    
    @objc private func keyboardUp() {
        if let message = self.message {
            input.setText(message.text)
        }
        expandMessageView()
    }
    
    @IBAction private func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction private func confirmTouch(_ sender: Any) {
        if let message = message {
            send?(message.text)
        }
    }
    
    // MARK: - aniimations
    
    private func sendMessage(_ text: String) {
        
        guard let profile = ProfileService.shared.profile else { return }
        
        let messageId = "\(profile.id.hashValue)-\(Date().hashValue)"
        let message = Message(id: messageId, createdAt: Date(), sender: profile.shortUser, type: .text, text: text, deliveredAt: nil, readAt: nil)
        let msgModel = MessageViewModel(message: message)
        
        self.message = message
        
        tableView.newMessage(msgModel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.collapseMessageView()
        }
    }
    
    private func edit() {
        expandMessageView()
    }
    
    private func collapseMessageView(duration: Double = 0.3, curve: UIView.AnimationOptions = .curveEaseInOut) {

        input.reset()
        if let message = message {
            tableView.setup(for: [MessageViewModel(message: message)])
            checkEmptyView()
        }

        let tableViewHeight = tableView.rect(forSection: 0).height + tableView.contentInset.top + tableView.contentInset.bottom
        let height = message != nil ? tableViewHeight : 80
        
        input.hideKeyboard()
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.beginFromCurrentState, curve],
            animations: {
                self.messagingViewHeight.constant = height
                self.confirmButton.alpha = 1
                self.superview?.layoutIfNeeded()
        },
            completion: { (_) in
                self.tableView.scrollToBottom()
        })
    }
    
    private func expandMessageView(duration: Double = 0.3, curve: UIView.AnimationOptions = .curveEaseInOut) {
        
        let height = CGFloat(80)
    
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.beginFromCurrentState, curve],
            animations: {
                self.messagingViewHeight.constant = height
                self.tableView.setup(for: [])
                self.confirmButton.alpha = 0
                self.checkEmptyView()
                self.superview?.layoutIfNeeded()
            },
            completion: { (_) in
                if let message = self.message {
                    self.input.setText(message.text)
                }
                self.input.showKeyboard()
            })
    }
    
    // MARK: - empty view
    
    private class EmptyView: UIView {
        
        private let label: UILabel = {
           let label = UILabel()
            label.font = UIFont(name: "Avenir-Medium", size: 15) ?? UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(red: 124, green: 139, blue: 155)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            return label
        }()
        
        convenience init() {
            self.init(frame: .zero)
            self.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(label)
            label.topAnchor.constraint(equalTo: topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
        }
        
        func setup(for user: ShortUser? = nil) {
            if let user = user {
                label.text = "Please leave \(user.name) a heads up about why you decided to cancel."
            } else {
                label.text = "Please leave the group a heads up about why you decided to cancel."
            }
        }
        
    }
    
    private var emptyView: EmptyView? {
        didSet {
            checkEmptyView()
        }
    }
    
    private func checkEmptyView() {
        guard let emptyView = emptyView else { return }
        
        if tableView.numberOfRows(inSection: 0) == 0 {
            guard emptyView.superview == nil else { return }
            
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            emptyView.setContentHuggingPriority(.defaultLow, for: .vertical)
            emptyView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            emptyView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            emptyView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            insertSubview(emptyView, belowSubview: input)
            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            emptyView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
            emptyView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
            emptyView.setNeedsLayout()
        } else {
            emptyView.removeFromSuperview()
        }
    }
    
}
