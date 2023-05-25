//
//  ChatView.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ChatView: LoadableView {
    
    @IBOutlet weak var tableView: ChatTableView!
    @IBOutlet weak var input: MessagingInputBar!
    
    var insets: UIEdgeInsets {
        get {
            return tableView.contentInset
        }
        set {
            tableView.contentInset = newValue
        }
    }
    
    var chat: Chat? {
        get {
            return tableView.chat
        }
        set {
            tableView.chat = newValue
            if let chat = newValue {
                setup(for: chat)
            }
        }
    }
    
    var showTyping: Bool {
        get {
            return tableView.showTyping
        }
        set {
            tableView.showTyping = newValue
        }
    }
    
    var send: ((_ text: String)->())?
    
    var showProfile: ((_ user: ShortUser)->())?
    
    var showExperience: ((_ experienceId: String)->())?
    
    var camera: (()->())?
    
    var placeholder: String? {
        get {
            return input.placeholder
        }
        set {
            input.placeholder = newValue
        }
    }
    
    override func setupNib() {
        super.setupNib()
        
        tableView.showProfile = { [weak self] user in
            self?.showProfile?(user)
        }
        
        tableView.showExperience = { [weak self] experienceId in
            self?.showExperience?(experienceId)
        }
        
        input.cameraTap = { [weak self] in
            self?.cameraTapped()
        }
        input.sendTap = { [weak self] (text) in
            self?.input.reset()
            self?.sendTapped(text)
        }
    }
    
    func setup(for chat: Chat) {
        input.showAvatar = false
        if let me = ProfileService.shared.profile?.shortUser {
            input.setup(for: me)
        }
    }
    
    func setup(for rows: [ChatCell]) {
        tableView.setup(for: rows)
    }
    
    func showKeyboard() {
        input.showKeyboard()
    }
    
    func hideKeyboard() {
        input.hideKeyboard()
    }
    
    func setInput(_ text: String) {
        input.setText(text)
    }
    
    func resetInput() {
        input.reset()
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func scrollToBottom() {
        tableView.scrollToBottom()
    }
    
    // MARK: - input bar
    
    private func cameraTapped() {
        camera?()
    }
    
    private func sendTapped(_ text: String) {
        send?(text)
    }
    
    // MARK: - handle messages
    
    func newMessage(_ message: Message) {
        tableView.newMessage(message)
    }
}

