//
//  ChatViewController.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Firebase

private let topBarId: Int = 123456

class ChatViewController: MoreBaseViewController {
    
    @IBOutlet private weak var topBarContainer: UIView!
    @IBOutlet private weak var topBarHeight: NSLayoutConstraint!
    @IBOutlet private weak var floatingButton: UIButton!
    @IBOutlet private weak var startCallButton: UIButton!
    @IBOutlet private weak var chatView: ChatView!
    @IBOutlet private weak var bottomPadding: NSLayoutConstraint!
    
    private(set) var chat: Chat? = nil
    
    // var requested: (()->())?
    // var removed: (()->())?
    
    var chatId: String? {
        return chat?.id
    }
    
    func getChatViewHeight() -> NSLayoutConstraint {
        return chatView.tableView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        floatingButton.layer.cornerRadius = 15
        
        chatView.placeholder = "Your message"
        chatView.insets = .zero
        chatView.send = { [weak self] (text) in
            self?.sendMessage(text)
        }
        chatView.camera = { [weak self] in
            self?.openAlbum()
        }
        chatView.showProfile = { [weak self] user in
            let root = self?.navigationController ?? self
            root?.presentUser(user.id)
        }
        chatView.showExperience = { [weak self] experienceId in
            let root = self?.navigationController ?? self
            root?.presentExperience(experienceId)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateChatData(_:)), name: ChatService.Notifications.ChatsLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateChat(_:)), name: ChatService.Notifications.ChatChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessages(_:)), name: ChatService.Notifications.ChatMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTyping(_:)), name: ChatService.Notifications.ChatTyping, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removed(_:)), name: ChatService.Notifications.ChatRemoved, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBars(_:)), name: ExperienceTrackingService.Notifications.ExperienceChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBars(_:)), name: ExperienceTrackingService.Notifications.ExperiencePost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBars(_:)), name: ExperienceTrackingService.Notifications.ExperiencePostChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBars(_:)), name: ExperienceTrackingService.Notifications.ExperiencePostExpired, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        setupTabBar()
        setupFloatingButton()
        trackTyping()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopTrackingTyping()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let frame = CGRect(x: 0, y: 26, width: topBarContainer.frame.width, height: 27)
        topBarContainer.enableShadow(color: .black, path: UIBezierPath(rect: frame).cgPath)
    }
    
    private var isFirst: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
        guard isFirst else { return }
        
        setupNavigationBar()
        
        bottomContraint = bottomPadding
        trackKeyboard(onlyFor: [chatView.input.textView])
        trackKeyboardAndPushUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
        guard isFirst else { return }
        isFirst = false
        
        chatView.scrollToBottom()
        resetUnreads()
    }
    
    private func close() {
        leaveCall()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func toBackground(_ notification: Notification) {
        leaveCall()
    }
    
    @objc private func keyboardUp(_ notification: Notification) {
        chatView.scrollToBottom()
    }
    
    @objc private func keyboardDown(_ notification: Notification) {
        // TODO: --
    }
    
    func setup(chat: Chat) {
        self.chat = chat
        
        setupNavigationBar()
        setupTopBar()
        setupFloatingButton()
        setupMessages()
        
        if chat.other().id == Id.More {
            chatView.input.isUserInteractionEnabled = false
            chatView.input.placeholder = ""
        }
    }
    
    private func setupNavigationBar() {
        
        navigationController?.navigationBar.barTintColor = .whiteTwo
        navigationController?.navigationBar.shadowImage = UIImage.onePixelImage(color: .iceBlue)
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.charcoalGrey,
            .font: UIFont(name: "Gotham-Medium", size: 14)!,
            .kern: 0.86
        ]
        
        let button = UIButton(type: .system)
        button.tintColor = .blueGrey
        button.setImage(UIImage(named: "more_dots"), for: .normal)
        button.isUserInteractionEnabled = false
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        setRightContent(button)
        rightTap = { [weak self] in
            guard let chat = self?.chat else { return }
            if chat.type == .group {
                self?.showGroupManagement()
            } else {
                self?.report(chat, complete: { (reported) in
                    if reported {
                        self?.close()
                    }
                })
            }
        }
        
        updateNavigationBar()
    }
    
    private func updateNavigationBar() {
        if let chat = chat {
            if chat.type == .group || chat.members.count > 2 {
                var leftView: GroupChatViewLeftHeader!
                if let content = leftContent as? GroupChatViewLeftHeader {
                    leftView = content
                } else {
                    let left = GroupChatViewLeftHeader()
                    left.translatesAutoresizingMaskIntoConstraints = false
                    left.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    setLeftContent(left)
                    left.gestureRecognizers?.forEach { left.removeGestureRecognizer($0) }
                    left.isUserInteractionEnabled = true
                    left.backTap = { [weak self] in
                        self?.close()
                    }
                    left.groupTap = { [weak self] in
                        self?.showGroup()
                    }
                    leftView = left
                }
                leftView.setup(for: chat)
            } else {
                var leftView: ChatViewLeftHeader!
                if let content = leftContent as? ChatViewLeftHeader {
                    leftView = content
                } else {
                    let left = ChatViewLeftHeader()
                    left.translatesAutoresizingMaskIntoConstraints = false
                    left.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    
                    setLeftContent(left)
                    left.gestureRecognizers?.forEach { left.removeGestureRecognizer($0) }
                    left.isUserInteractionEnabled = true
                    left.backTap = { [weak self] in
                        self?.close()
                    }
                    left.profileTap = { [weak self] in
                        let root = self?.navigationController ?? self
                        root?.presentUser(chat.other().id)
                    }
                    leftView = left
                }
                leftView.setup(for: chat.other())
            }
        } else {
            setLeftIcon(UIImage(named: "backward-arrow")!.resizedImage(size: CGSize(width: 20, height: 20)))
            leftTap = { [weak self] in
                self?.close()
            }
        }
    }
    
    private func setupTabBar() {
        hidesBottomBarWhenPushed = true
    }
    
    private func setupTopBar() {
        guard let chat = chat else { return }
        
        if let videoCall = chat.videoCall {
            setupCallTopBar(chat: chat)
            return
        }
        
        let experience = Chat.getExperience(for: chat)
        let post = Chat.getPost(for: chat)
        let request = Chat.getRequest(for: chat)
        // let time = Chat.getTime(for: chat)
        let now = Date()
        
        var removeTop = true
        if !(experience?.isVirtual ?? false),
            let post = post, post.creator.isMe(), post.isActive(now) {
            if post.chat?.id == chat.id {
                if !post.started {
                    setupStartTopBar(post: post, request: request)
                    removeTop = false
                }
            } else if let request = request {
                if post.creator.isMe() {
                    if chat.members.count > 2 {
                        if !post.started {
                            setupStartTopBar(post: post, request: request)
                            removeTop = false
                        }
                    } else {
                        if request.accepted == nil {
                            setupStartTopBar(post: post, request: request)
                            removeTop = false
                        }
                    }
                }
            }
            //        } else if let time = time {
            //            if !time.haveReviewed() {
            //                setupReviewTopBar(time)
            //                removeTop = false
            //            }
        }
        if removeTop {
            clearTopBar()
            topBarContainer.isHidden = true
            topBarHeight.constant = 0
        }
    }
    
    private func setupFloatingButton() {
        guard let chat = chat else {
            chatView.insets = .zero
            floatingButton.isHidden = true
            startCallButton.isHidden = true
            return
        }
        
        guard !setupStartCallButton(chat: chat) else {
            chatView.insets = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
            floatingButton.isHidden = true
            startCallButton.isHidden = true
            return
        }
        
        startCallButton.isHidden = true
        if let post = Chat.getPost(for: chat),
            post.creator.isMe(),
            let requests = post.requests,
            !requests.filter({ $0.accepted == nil && !chat.members.contains($0.creator) }).isEmpty {
            chatView.insets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
            floatingButton.isHidden = true
        } else {
            chatView.insets = .zero
            floatingButton.isHidden = true
        }
    }
    
    // MARK: - top bar
    
    private func clearTopBar() {
        topBarContainer.viewWithTag(topBarId)?.removeFromSuperview()
    }
    
    private func setupReviewTopBar(_ time: Time) {
        clearTopBar()
        
        let bar = ChatReviewTopBar()
        bar.tag = topBarId
        bar.setup(for: time)
        bar.translatesAutoresizingMaskIntoConstraints = false
        topBarContainer.addSubview(bar)
        bar.topAnchor.constraint(equalTo: topBarContainer.topAnchor).isActive = true
        bar.leftAnchor.constraint(equalTo: topBarContainer.leftAnchor).isActive = true
        bar.rightAnchor.constraint(equalTo: topBarContainer.rightAnchor).isActive = true
        bar.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        bar.buttonTap = { [weak self] in
            self?.reviewTopBarTouch()
        }
        
        topBarContainer.isHidden = false
        topBarHeight.constant = 53
    }
    
    private func setupStartTopBar(post: ExperiencePost, request: ExperienceRequest?) {
        
        var topBar: ChatViewStartTimeBar!
        if let top = topBarContainer.viewWithTag(topBarId) as? ChatViewStartTimeBar {
            topBar = top
        } else {
            clearTopBar()
            let bar = ChatViewStartTimeBar()
            bar.tag = topBarId
            bar.translatesAutoresizingMaskIntoConstraints = false
            topBarContainer.addSubview(bar)
            bar.topAnchor.constraint(equalTo: topBarContainer.topAnchor).isActive = true
            bar.leftAnchor.constraint(equalTo: topBarContainer.leftAnchor).isActive = true
            bar.rightAnchor.constraint(equalTo: topBarContainer.rightAnchor).isActive = true
            bar.heightAnchor.constraint(equalToConstant: 52).isActive = true
            bar.startTap = { [weak self] in
                self?.startTopBarTouch()
            }
            bar.meetTap = { [weak self] in
                self?.meetTopBarTouch()
            }
            topBar = bar
        }
        topBar.setup(for: post)
        
        topBarContainer.isHidden = false
        topBarHeight.constant = 53
    }
    
    private func setupCallTopBar(chat: Chat) {
        
        var topBar: ChatViewJoinCallBar!
        if let top = topBarContainer.viewWithTag(topBarId) as? ChatViewJoinCallBar {
            topBar = top
        } else {
            clearTopBar()
            let bar = ChatViewJoinCallBar()
            bar.tag = topBarId
            bar.translatesAutoresizingMaskIntoConstraints = false
            topBarContainer.addSubview(bar)
            bar.topAnchor.constraint(equalTo: topBarContainer.topAnchor).isActive = true
            bar.leftAnchor.constraint(equalTo: topBarContainer.leftAnchor).isActive = true
            bar.rightAnchor.constraint(equalTo: topBarContainer.rightAnchor).isActive = true
            bar.heightAnchor.constraint(equalToConstant: 52).isActive = true
            bar.jointTap = { [weak self] in
                self?.joinOrLeaveCall()
            }
            topBar = bar
        }
        topBar.setup(for: chat, canJoin: canJoin)
        
        topBarContainer.isHidden = false
        topBarHeight.constant = 53
    }
    
    // MARK: - messages
    
    private func setupMessages() {
        if var chat = chat {
            
            if let updated = ChatService.shared.getChats().first(where: { $0.id == chat.id }) {
                chat = updated
            }
            
            chatView.chat = chat
            let cells: [ChatCell] = chat.messages?.map { ChatCell(type: .message, message: $0) } ?? []
            chatView.setup(for: cells)
            calculateTyping()
        }
    }
    
    private func resetUnreads() {
        if let chat = chat,
            let unreadList = chat.messages?.filter({ !$0.isMine() && !$0.haveRead() }),
            unreadList.count > 0 {
            
            DispatchQueue.global(qos: .default).async {
                for message in unreadList {
                    ChatService.shared.setMessageRead(chatId: chat.id, messageId: message.id)
                }
            }
        }
    }
    
    // MARK: - buttons
    
    private func reviewTopBarTouch() {
        guard let chat = chat else { return }
        
        //        let time = Chat.getTime(for: chat)
        //
        //        if let time = time {
        //            if !time.haveReviewed() {
        //                if let nc = navigationController as? MoreTabBarNestedNavigationController {
        //                    nc.presentReview(for: time)
        //                }
        //            }
        //        }
        
    }
    
    private func startTopBarTouch() {
        guard let chat = chat else { return }
        guard let post = Chat.getPost(for: chat) else { return }
        
        if post.meeting == nil {
            let alert = UIAlertController(title: "Meet point", message: "Please choose a meetint point before starting the time.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        if post.creator.isMe() {
            showLoading()
            ExperienceService.shared.startPost(experienceId: post.experience.id, postId: post.id, chat: chat) { [weak self] (success, _) in
                self?.hideLoading()
                self?.setupTabBar()
            }
        }
    }
    
    private func meetTopBarTouch() {
        guard let chat = chat else { return }
        guard let post = Chat.getPost(for: chat) else { return }
        let request = Chat.getRequest(for: chat)
        
        // show meeting selector
        // ...
        
        let vc = ChatMeetingSelectorViewController()
        _ = vc.view
        vc.back = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.selected = { [weak self] (location, name, address, type) in
            
            if let location = location {
                // update
                ExperienceService.shared.updateExperiencePostMeetingLocation(experienceId: post.experience.id, postId: post.id, location: location, name: name, address: address, type: type, complete: nil)
                
                // notify in chat
                guard let me = ProfileService.shared.profile?.shortUser else { return }
                let messageId = "\(me.id.hashValue)-\(Date().hashValue)"
                let additional = Message.additionalMeetingData(location: location, name: name ?? "", address: address ?? "")
                let additionalData = Message.additionalData(from: additional)
                let meetMsg = Message(id: messageId, createdAt: Date(), sender: me, type: .meeting, text: "", additionalData: additionalData, deliveredAt: nil, readAt: nil)
                ChatService.shared.sendMessage(chatId: chat.id, message: meetMsg)
            }
            
            self?.dismiss(animated: true, completion: nil)
        }
        present(vc, animated: true, completion: nil)
        
        vc.setup(post: post, request: request, location: post.meeting, name: post.meetingName, address: post.meetingAddress, type: post.meetingType)
    }
    
    // MARK: - data changes
    
    @objc private func updateChatData(_ notice: Notification) {
        
        DispatchQueue.main.async { [weak self] in
            guard let chat = self?.chat else { return }
            guard let updated = ChatService.shared.getChats().first(where: { $0.id == chat.id }) else { return }
            
            self?.setup(chat: updated)
            self?.resetUnreads()
        }
    }
    
    @objc private func updateMessages(_ notice: Notification) {
        
        DispatchQueue.main.async { [weak self] in
            guard let chat = self?.chat else { return }
            guard let chatId =  notice.userInfo?["chatId"] as? String, chat.id == chatId else { return }
            guard let updated = ChatService.shared.getChats().first(where: { $0.id == chat.id }) else { return }
            
            self?.setup(chat: updated)
            
            guard let msgId = notice.userInfo?["messageId"] as? String, let msg = chat.messages?.first(where: { $0.id == msgId }) else { return }
            
            if !msg.isMine() && !msg.haveRead() {
                DispatchQueue.global(qos: .default).async {
                    ChatService.shared.setMessageRead(chatId: chat.id, messageId: msgId)
                }
            }
        }
    }
    
    @objc private func updateTyping(_ notice: Notification) {
        
        DispatchQueue.main.async { [weak self] in
            guard let chatId =  notice.userInfo?["chatId"] as? String, self?.chat?.id == chatId else { return }
            
            self?.calculateTyping()
        }
    }
    
    @objc private func removed(_ notice: Notification) {
        
        DispatchQueue.main.async { [weak self] in
            guard let chatId =  notice.userInfo?["chatId"] as? String, self?.chat?.id == chatId else { return }
            
            self?.close()
        }
    }
    
    @objc private func updateBars(_ notice: Notification) {
        
        DispatchQueue.main.async { [weak self] in
            guard let chat = self?.chat else { return }
            
            let experienceId = notice.userInfo?["experienceId"] as? String ?? (notice.userInfo?["experience"] as? Experience)?.id
            guard experienceId != nil else { return }
            
            let postId = notice.userInfo?["postId"] as? String ??
                (notice.userInfo?["post"] as? ExperiencePost)?.id
            guard postId == nil || postId == Chat.getPost(for: chat)?.id else { return }
            
            self?.updateNavigationBar()
            self?.setupTopBar()
            self?.setupFloatingButton()
        }
    }
    
    @objc private func updateChat(_ notice: Notification) {
        
        DispatchQueue.main.async { [weak self] in
            guard let chat = self?.chat else { return }
            guard let chatId = (notice.userInfo?["chat"] as? Chat)?.id, chatId == chat.id else { return }
            guard let updated = ChatService.shared.getChats().first(where: { $0.id == chat.id }) else { return }
            
            self?.chat = updated
            
            self?.setupNavigationBar()
            self?.setupTopBar()
            self?.setupFloatingButton()
        }
    }
    
    // MARK: - send message
    
    private func sendMessage(_ text: String) {
        guard let profile = ProfileService.shared.profile else { return }
        
        let messageId = "\(profile.id.hashValue)-\(Date().hashValue)"
        let message = Message(id: messageId, createdAt: Date(), sender: profile.shortUser, type: .text, text: text.trimmingCharacters(in: .whitespacesAndNewlines), deliveredAt: nil, readAt: nil)
        sendMessage(message)
    }
    
    func sendMessage(_ message: Message) {
        guard let chat = chat else { return }
        
        chatView.newMessage(message)
        ChatService.shared.sendMessage(chatId: chat.id, message: message)
    }
    
    // MARK: - typing
    
    private func trackTyping() {
        // me typing
        chatView.input.isTypingChanged = { [weak self] in
            guard let chat = self?.chat else { return }
            guard let isTyping = self?.chatView.input.isTyping else { return }
            
            ChatService.shared.setTyping(typing: isTyping, in: chat.id)
        }
    }
    
    private func stopTrackingTyping() {
        chatView.input.isTypingChanged = nil
    }
    
    private func calculateTyping() {
        guard let chat = self.chat else { return }
        guard let updatedChat = ChatService.shared.getChats().first(where: { $0.id == chat.id}) else { return }
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        
        let typing = !updatedChat.typing.filter({ $0 != myId }).isEmpty
        chatView.showTyping = typing
    }
    
    // MARK: - group management
    
    @IBAction private func floatingButtonTouch(_ sender: Any) {
        showGroupManagement()
    }
    
    private func showGroup() {
        guard let chat = chat else { return }
        
        if let post = Chat.getPost(for: chat), post.creator.isMe() {
            showGroupManagement()
        } else {
            let root = navigationController ?? self
            if chat.members.count > 2 {
                root.presentGroup(chat.members)
            } else {
                root.presentUser(chat.other().id)
            }
        }
    }
        
        
    private func showGroupManagement() {
        guard let chat = chat else { return }
        
        let root = navigationController?.view ?? self.view!
        
        var post = Chat.getPost(for: chat)
        post = post?.creator.isMe() == true ? post : nil
        let overlay = ChatGroupManagementView()
        overlay.setup(for: chat, post: post)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(overlay)
        
        overlay.leadingAnchor.constraint(equalTo: root.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: root.trailingAnchor).isActive = true
        overlay.topAnchor.constraint(equalTo: root.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: root.bottomAnchor).isActive = true
        
        root.layoutIfNeeded()
        
        overlay.setupForEnterFromAbove()
        overlay.enterFromAbove()
        
        overlay.close = { [weak overlay] in
            overlay?.exitFromAbove({
                overlay?.removeFromSuperview()
            })
        }
        
        overlay.add = { [weak self] in
            guard let experience = Chat.getExperience(for: chat) else { return }
            LinkService.shareExperienceLink(experience: experience, complete: { (url) in
                guard let vc = self else { return }
                ShareService.shareSignal(link: url, from: vc, complete: { success in
                    if success {
                        ExperienceService.shared.shareExperience(experience: experience, completion: nil)
                    }
                })
            })
        }
        
        overlay.selectedUser = { [weak self] user in
            let root = self?.navigationController ?? self
            root?.presentUser(user.id)
        }
        
        overlay.addUser = { [weak overlay, weak self] user in
            guard let chat = self?.chat else { return }
            guard let post = Chat.getPost(for: chat) else { return }
            guard let request = post.request(from: user.id) else { return }
            overlay?.isUserInteractionEnabled = false
            
            // update data
            var members = chat.members
            members.append(user)
            let updatedChat = chat.chatWithMembers(members)
            var requests = post.requests
            if let idx = requests?.firstIndex(of: request) {
                requests?.remove(at: idx)
                requests?.append(request.requestWithAccepted(true))
            }
            let updatedPost = post.postWithRequests(requests)
            
            if chat.type == .group || chat.members.count > 2 {
                //  group chat is ready to add members
                ExperienceService.shared.acceptRequest(experienceId: post.experience.id, postId: post.id, requestId: request.id) { (success, _) in
                    if success {
                        overlay?.setup(for: updatedChat, post: updatedPost)
                        overlay?.isUserInteractionEnabled = true
                    }
                }
            } else {
                // need to switch to group chat
                guard let me = ProfileService.shared.profile?.shortUser else { return }
                
                let users = members.filter { $0.id != me.id }
                ExperienceService.shared.acceptRequests(post: post, users: users, complete: {
  
                    let chat = Chat(
                        id: "-",
                        createdAt: Date(),
                        members: members,
                        type: .group,
                        messages: nil,
                        typing: [],
                        creator: me)
                    
                    ChatService.shared.createChat(chat: chat) { (chatId, errorMsg) in
                        if let chatId = chatId {
                            ExperienceService.shared.updatePostChat(experienceId: post.experience.id, postId: post.id, chat: chat.chatWithId(chatId)) { (success, _) in
                                self?.hideLoading()
                                
                                ChatService.shared.getChat(chatId: chatId) { (newChat) in
                                    if let newChat = newChat {
                                        self?.setup(chat: newChat)
                                        overlay?.setup(for: newChat, post: updatedPost)
                                    }
                                    overlay?.isUserInteractionEnabled = true
                                }
                                
                                // announce message
                                let msgId = "\(me.id.hashValue)-\(Date().hashValue)"
                                let msg = Message(id: msgId, createdAt: Date(), sender: me, type: .created, text: "\(me.name) created the group", deliveredAt: nil, readAt: nil)
                                ChatService.shared.sendMessage(chatId: chatId, message: msg)
                            }
                        } else {
                            overlay?.isUserInteractionEnabled = true
                        }
                    }
                })
            }
        }
        
        overlay.removeUser = { [weak overlay, weak self] user in
            guard let chat = self?.chat else { return }
            
            if let post = Chat.getPost(for: chat) {
                guard let request = post.request(from: user.id) else { return }
                overlay?.isUserInteractionEnabled = false
                ExperienceService.shared.cancelRequest(experienceId: post.experience.id, postId: post.id, requestId: request.id) { (success, _) in
                    if success {
                        var members = chat.members
                        members.removeAll(where: { $0.id == user.id })

                        if members.filter({ !$0.isMe() }).count <= 0 {
                            overlay?.close?()
                            return
                        }
                        
                        let updatedChat = chat.chatWithMembers(members)
                        var requests = post.requests
                        if let idx = requests?.firstIndex(of: request) {
                            requests?.remove(at: idx)
                            requests?.append(request.requestWithAccepted(false))
                        }
                        let updatedPost = post.postWithRequests(requests)
                        overlay?.setup(for: updatedChat, post: updatedPost)
                    }
                    overlay?.isUserInteractionEnabled = true
                }
            } else {
                overlay?.isUserInteractionEnabled = false
                ChatService.shared.getChat(chatId: chat.id) { (chat) in
                    guard let chat = chat,
                        let userInChat = chat.members.first(where: { $0.id == user.id }) else {
                            overlay?.isUserInteractionEnabled = true
                            return
                    }
                    ChatService.shared.removeFromChat(chatId: chat.id, user: userInChat) { (success, _) in
                        if success {
                            var members = chat.members
                            members.removeAll(where: { $0.id == user.id })
                            
                            if members.filter({ !$0.isMe() }).count <= 0 {
                                overlay?.close?()
                                ChatService.shared.deleteChat(chatId: chat.id, complete: nil)
                                return
                            }
                            
                            let updatedChat = chat.chatWithMembers(members)
                            overlay?.setup(for: updatedChat, post: nil)
                        }
                    }
                }
            }
        }
    }
    
}
