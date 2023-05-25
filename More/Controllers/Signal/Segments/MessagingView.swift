//
//  MessagingView.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit


@IBDesignable
class MessagingView: LoadableView {
    
    @IBOutlet weak var tableView: MessagingTableView!
    @IBOutlet weak var input: MessagingInputBar!
    
    var insets: UIEdgeInsets {
        get {
            return tableView.contentInset
        }
        set {
            tableView.contentInset = newValue
        }
    }
    
    var isEditable: Bool {
        get {
            return tableView.isEditable
        }
        set {
            tableView.isEditable = newValue
        }
    }
    
    var timeFormat: String {
        get {
            return tableView.timeFormat
        }
        set {
            tableView.timeFormat = newValue
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
    
    var height: CGFloat {
        get {
            return 74 + tableView.rect(forSection: 0).height + tableView.contentInset.top + tableView.contentInset.bottom
        }
    }
    
    var send: ((_ text: String)->())?
    
    var edit: ((_ message: MessageViewModel)->())?
    
    var emptyView: UIView? {
        didSet {
            checkEmptyView()
        }
    }
    
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
        
        input.cameraTap = { [weak self] in
            self?.cameraTapped()
        }
        input.sendTap = { [weak self] (text) in
            self?.input.reset()
            self?.sendTapped(text)
        }
        
        tableView.edit = { [weak self] (message) in
            self?.edit?(message)
        }
    }
    
    func setup(for user: UserViewModel) {
        input.showAvatar = true
        input.setup(for: user.user.short())
    }
    
    func setup(for rows: [MessageViewModel]) {
        tableView.setup(for: rows)
        checkEmptyView()
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
        // nothign for now
    }
    
    private func sendTapped(_ text: String) {
        send?(text)
    }
    
    // MARK: - handle messages
    
    func newMessage(_ message: MessageViewModel) {
        tableView.newMessage(message)
        checkEmptyView()
    }
    
    // MARK: - empty view
    
    private func checkEmptyView() {
        guard let emptyView = emptyView else { return }
        
        if tableView.numberOfRows(inSection: 0) == 0 {
            guard emptyView.superview == nil else { return }
            
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(emptyView, belowSubview: input)
            emptyView.leftAnchor.constraint(equalTo: tableView.leftAnchor).isActive = true
            emptyView.rightAnchor.constraint(equalTo: tableView.rightAnchor).isActive = true
            emptyView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
            emptyView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
            emptyView.setNeedsLayout()
        } else {
            emptyView.removeFromSuperview()
        }
    }

}
