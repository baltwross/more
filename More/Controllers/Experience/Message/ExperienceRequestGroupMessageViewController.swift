//
//  ExperienceRequestGroupMessageViewController.swift
//  More
//
//  Created by Luko Gjenero on 03/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ExperienceRequestGroupMessageViewController: ExperienceRequestViewController {
    
    @IBOutlet private weak var panel: UIView!
    @IBOutlet private weak var topBarContainer: UIView!
    @IBOutlet private weak var topBar: GroupChatViewLeftHeader!
    @IBOutlet private weak var messagingView: MessagingView!
    @IBOutlet private weak var messagingViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var confirmContainer: UIView!
    @IBOutlet private weak var confirm: ExperienceRequestGroupBar!
    @IBOutlet private weak var bottomPadding: NSLayoutConstraint!
    
    private var experience: Experience?
    private var post: ExperiencePost?
    private var emptyView = RequestEmptyView()
    private var message: Message? = nil
    private var isConfirm: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panel.enableShadow(color: .black)
        
        topBarContainer.isHidden = true
        
        topBar.backTap = { [weak self] in
            self?.isConfirm = false
            self?.confirm.setupForRequest()
            self?.collapseMessageView(fully: true)
        }
        
        messagingView.insets = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        messagingView.send = { [weak self] (text) in
            self?.sendMessage(text)
        }
        messagingView.edit = { [weak self] (text) in
            self?.expandMessageView()
        }
        messagingView.placeholder = "Say why this sounds fun"
        messagingView.timeFormat = "Confirm to deliver"
        messagingView.isEditable = true
        messagingViewHeight.constant = 73
        
        emptyView.isExpanded = true
        emptyView.skipTap = { [weak self] in
            self?.sendMessage(nil)
        }
        emptyView.editTap = { [weak self] in
            self?.expandMessageView()
        }
        messagingView.emptyView = emptyView
        
        confirmContainer.isHidden = false
        confirm.buttonTap = { [weak self] in
            if self?.experience?.isVirtual == true || self?.isConfirm == true {
                self?.request()
            } else {
                self?.isConfirm = true
                self?.confirm.setupForConfirm()
                self?.expandMessageView()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var isFirst: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard isFirst else { return }
        
        bottomContraint = bottomPadding
        trackKeyboard(onlyFor: [messagingView.input.textView])
        trackKeyboardAndPushUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        if TutorialService.shared.shouldShow(tutorial: .join) {
            let anchor = confirm.button.convert(CGPoint(x: confirm.button.bounds.midX, y: 0), to: view)
            TutorialService.shared.show(tutorial: .join, anchor: anchor, container: view, above: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let maskPath = UIBezierPath(roundedRect: topBarContainer.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 12.0, height: 12.0))
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        topBarContainer.layer.mask = shape
    }
    
    // MARK: - collapse / expand
    
    private func collapseMessageView(fully: Bool = false, duration: Double = 0.3, curve: UIView.AnimationOptions = .curveEaseInOut, force: Bool = false) {
        
        messagingView.tableView.showTyping = false
        messagingView.resetInput()
        if let message = message {
            messagingView.setup(for: [MessageViewModel(message: message)])
        }
        
        let messageViewHeight =  message == nil ? 140 : messagingView.height
        let height = fully ? 73 : messageViewHeight
        
        guard self.messagingViewHeight.constant > height || force else { return }
        
        messagingView.hideKeyboard()
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.beginFromCurrentState, curve],
            animations: {
                self.messagingViewHeight.constant = height
                self.confirmContainer.alpha = 1
                self.emptyView.isExpanded = false
                self.messagingView.insets = .zero
                self.topBarContainer.isHidden = fully
                
                self.view.layoutIfNeeded()
        },
            completion: { (_) in
                self.messagingView.scrollToBottom()
        })
    }
    
    private func expandMessageView(duration: Double = 0.3, curve: UIView.AnimationOptions = .curveEaseInOut, force: Bool = false) {
        
        let height = max(260, messagingView.height)
        
        guard self.messagingViewHeight.constant < height || force else { return }
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.beginFromCurrentState, curve],
            animations: {
                self.messagingViewHeight.constant = height
                self.confirmContainer.alpha = 0
                self.emptyView.isExpanded = true
                self.messagingView.setup(for: [])
                self.topBarContainer.isHidden = false
                
                self.view.layoutIfNeeded()
        },
            completion: { (_) in
                if let message = self.message {
                    self.messagingView.setInput(message.text)
                }
                self.messagingView.showKeyboard()
        })
    }
    
    // MARK: - ui
    
    private func sendMessage(_ text: String?) {
        guard let profile = ProfileService.shared.profile else { return }
        
        if let text = text {
            let messageId = "\(profile.id.hashValue)-\(Date().hashValue)"
            let message = Message(id: messageId, createdAt: Date(), sender: profile.shortUser, type: .text, text: text, deliveredAt: nil, readAt: nil)
            
            messagingView.newMessage(MessageViewModel(message: message))
            self.message = message
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.collapseMessageView()
        }
    }
    
    // MARK: - public methods
    
    override func setup(for experience: Experience) {
        guard let post = experience.activePost() else { return }
        
        self.experience = experience
        self.post = post
        
        topBar.setup(for: post)
        
        if let user = ProfileService.shared.profile?.user {
            messagingView.setup(for: UserViewModel(user: user))
        }
        emptyView.setup(for: post.creator.short())
        
        confirm.setup(for: post)
        
        if post.creator.isMe() || post.myRequest() != nil {
            panel.isHidden = true
        }
    }
    
    override func fullyCollapse(animated: Bool = true) {
        messagingView.hideKeyboard()
    }
    
    override var isCollapsed: Bool {
        return messagingView.input.textView.isFirstResponder
    }
    
    // MARK: - interaction
    
    private func request() {
        showLoading()
        
        if LocationService.shared.currentLocation != nil {
            internalRequest()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: LocationService.Notifications.LocationUpdate, object: nil)
        }
    }
    
    @objc private func locationUpdated() {
        NotificationCenter.default.removeObserver(self, name: LocationService.Notifications.LocationUpdate, object: nil)
        internalRequest()
    }
    
    private func internalRequest() {
        guard let experience = experience,
            let post = post,
            let user = ProfileService.shared.profile?.shortUser else { return }
        
        let request = ExperienceRequest(
            id: "",
            createdAt: Date(),
            creator: user,
            post: post.short(),
            message: message?.text)
        
        ExperienceService.shared.createExperienceRequest(for: experience, post: post, request: request) { [weak self] (requestId, errorMsg) in
            self?.hideLoading()
            if requestId != nil {
                self?.done?()
            }
        }
    }
}
