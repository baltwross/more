//
//  ExperienceRequestSingleMessageViewController.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ExperienceRequestSingleMessageViewController: ExperienceRequestViewController {
    
    @IBOutlet private weak var panel: UIView!
    @IBOutlet private weak var topBarContainer: UIView!
    @IBOutlet private weak var topBar: ChatViewLeftHeader!
    @IBOutlet private weak var walking: UIView!
    @IBOutlet private weak var distance: UILabel!
    @IBOutlet private weak var messagingView: MessagingView!
    @IBOutlet private weak var messagingViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var confirmContainer: UIView!
    @IBOutlet private weak var confirm: ExperienceRequestSingleBar!
    @IBOutlet private weak var bottomPadding: NSLayoutConstraint!
    
    private var experience: Experience?
    private var post: ExperiencePost?
    private var emptyView = RequestEmptyView()
    private var message: Message? = nil
    private var isConfirm: Bool = false
    
    var profile: (()->())?
    var deleted: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panel.enableShadow(color: .black)
        
        topBarContainer.isHidden = true
        
        topBar.backTap = { [weak self] in
            self?.isConfirm = false
            self?.confirm.setupForRequest()
            self?.collapseMessageView(fully: true)
        }
        
        topBar.profileTap = { [weak self] in
            self?.profile?()
        }
        
        walking.addWalkingAnimation()
        walking.lottieView?.play()
        
        messagingView.insets = .zero
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
        emptyView.setContentHuggingPriority(.defaultLow, for: .vertical)
        emptyView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        emptyView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        emptyView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        messagingView.emptyView = emptyView
        
        confirmContainer.isHidden = false
        confirm.profileTap = { [weak self] in
            self?.profile?()
        }
        confirm.joinTap = { [weak self] in
            self?.joinOrLeave()
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
            let anchor = confirm.joinButton.convert(CGPoint(x: confirm.joinButton.bounds.midX, y: 0), to: view)
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
    
    // MARK: - join / leave
    
    private func joinOrLeave() {
        guard let post = experience?.posts?.first else { return }
        
        if post.creator.isMe() {
            delete(post)
        } else if experience?.isVirtual == true || isConfirm == true {
            request()
        } else {
            isConfirm = true
            confirm.setupForConfirm()
            expandMessageView()
        }
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
        guard let post = experience.posts?.first else { return }
        
        self.experience = experience
        self.post = post
        
        topBar.setup(for: post.creator.short())
        
        if let user = ProfileService.shared.profile?.user {
            messagingView.setup(for: UserViewModel(user: user))
        }
        emptyView.setup(for: post.creator.short())
        
        confirm.setup(for: post)
        
        distance.text = "..."
        loadDistance(from: post.creator.short())
        
        if (post.creator.isMe() && (post.requests?.count ?? 0) > 0) || post.myRequest() != nil {
            panel.isHidden = true
        }
    }
    
    private func loadDistance(from user: ShortUser) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        GeoService.shared.getDistance(from: myId, to: user.id) { [weak self] (distance) in
            self?.distance.text = "\(Formatting.formatFeetAway(distance.metersToFeet())) away"
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
    
    private func delete(_ post: ExperiencePost) {
        let alert = UIAlertController(title: "Leave This Time?", message: "You will be removed from the group and will lose access to related conversations and calls.", preferredStyle: .alert)
        
        let report = UIAlertAction(title: "Leave", style: .destructive, handler: { [weak self] _ in
            self?.internalDelete(post)
        })
        
        alert.addAction(report)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    private func internalDelete(_ post: ExperiencePost) {
        showLoading()
        ExperienceService.shared.deletePost(experienceId: post.experience.id, postId: post.id, complete: { [weak self] (success, errorMsg) in
            self?.hideLoading()
            if success {
                self?.deleted?()
            }
        })
    }
}


