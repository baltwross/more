//
//  RequestsViewController.swift
//  More
//
//  Created by Luko Gjenero on 28/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import AVKit

private let singleCell = String(describing: RequestsViewTableViewCell.self)
private let groupCell = String(describing: GroupRequestTableViewCell.self)
private let activeCell = String(describing: ActiveRequestsTableViewCell.self)

class RequestsViewController: MoreBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var search: CreateSignalPlaceSearchView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var activeExperiences: [Experience] = []
    private var chats: [Chat] = []
    
    private var filterText: String? = nil
    private var filteredActivePosts: [ExperiencePost] = []
    private var filteredChats: [Chat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.placeholder = "Search"
        search.searchChanged = { [weak self] text in
            // TODO  - filter
            self?.filter(with: text)
        }
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        tableView.estimatedRowHeight = 95
        tableView.rowHeight = 95
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UINib(nibName: singleCell, bundle: nil), forCellReuseIdentifier: singleCell)
        tableView.register(UINib(nibName: groupCell, bundle: nil), forCellReuseIdentifier: groupCell)
        tableView.register(UINib(nibName: activeCell, bundle: nil), forCellReuseIdentifier: activeCell)
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ChatService.Notifications.ChatsLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ChatService.Notifications.ChatChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ChatService.Notifications.ChatMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ChatService.Notifications.ChatRemoved, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ExperienceTrackingService.Notifications.ExperienceChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ExperienceTrackingService.Notifications.ExperiencePost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ExperienceTrackingService.Notifications.ExperiencePostChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ExperienceTrackingService.Notifications.ExperiencePostExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ExperienceTrackingService.Notifications.ExperienceRequest, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ExperienceTrackingService.Notifications.ExperienceResponse, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBuffered), name: ProfileService.Notifications.BlockedLoaded, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        reload()
    }
    
    private func setupNavigationBar() {
        setTitle("Inbox")
        
        // back
        if let nc = navigationController, nc.viewControllers.count > 0 {
            setLeftIcon(UIImage(named: "backward-arrow")!.resizedImage(size: CGSize(width: 20, height: 20)))
            leftTap = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        // settings
        setRightIcon(UIImage(named: "requests-inbox-add")!)
        rightTap = { [weak self] in
            // TODO: -- what to show here?
        }
        
        removeRight()
    }
    
    // MARK: - data
    
    private var isReloading: Bool = false
    private var needsReloading: Bool = false
    @objc private func reloadBuffered() {
        guard !isReloading else {
            needsReloading = true
            return
        }
        isReloading = true
        needsReloading = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.reload()
            self?.isReloading = false
            if self?.needsReloading == true {
                self?.reloadBuffered()
            }
        }
    }
    
    @objc private func reload() {
        activeExperiences = ExperienceTrackingService.shared.getActiveExperiences()
        chats = ChatService.shared.getChats().filter { !ProfileService.shared.blocked.contains($0.other().id) }
        chats.sort { (lhs, rhs) -> Bool in
            return lhs.latestUpdate() > rhs.latestUpdate()
        }
        filter(with: filterText)
        tableView.reloadData()
    }
    
    var activePosts: [ExperiencePost] {
        var posts: [ExperiencePost] = []
        let now = Date()
        for experience in activeExperiences {
            if let post = experience.myPost(), post.isActive(now),
                post.requests?.first(where: { $0.accepted != false}) != nil {
                posts.append(post)
                continue
            }
            if let request = experience.myRequest(), !(request.accepted == false),
                let post = experience.post(for: request.id), post.isActive(now) {
                posts.append(post)
            }
        }
        return posts
    }
    
    var activeChats: [Chat] {
        var chats: [Chat] = []
        let active = activePosts
        for chat in self.chats {
            if active.first(where: { $0.chat?.id == chat.id }) != nil {
                chats.append(chat)
                continue
            }
            
            if !(chat.type == .group) && chat.members.count == 2 {
                if let post = active.first(where: { $0.creator.id == chat.other().id }),
                    post.myRequest() != nil, post.chat == nil {
                    chats.append(chat)
                    continue
                }
                
                if active.contains(where: { $0.creator.isMe() && $0.request(from: chat.other().id) != nil && $0.chat == nil }) {
                    chats.append(chat)
                    continue
                }
            }
        }
        return chats
    }
    
    var inactiveChats: [Chat] {
        let active = activeChats
        return self.chats.filter { !active.contains($0) }
    }
    
    // MARK: - filtering
    
    private func filter(with text: String?) {
        filterText = text
        if let text = text?.lowercased(), !text.isEmpty {
         
            // filtering by member name
            var chats: [Chat] = []
            for chat in inactiveChats {
                for member in chat.others() {
                    if member.name.lowercased().contains(text) {
                        chats.append(chat)
                        break
                    }
                }
            }
            filteredChats = chats
            
            // filtering by requester name
            var posts: [ExperiencePost] = []
            for post in activePosts {
                for request in post.requests ?? [] {
                    if request.creator.name.lowercased().contains(text) {
                        posts.append(post)
                        break
                    }
                }
            }
            filteredActivePosts = posts
            
        } else {
            filteredChats = inactiveChats
            filteredActivePosts = activePosts
        }
        tableView.reloadData()
    }
    
    private func open(chat: Chat) {
        if chat.other().id == Id.More {
            let videoURL = URL(string: Urls.welcomeVideo)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
            if let unreadList = chat.messages?.filter({ !$0.isMine() && !$0.haveRead() }),
                unreadList.count > 0 {
                DispatchQueue.global(qos: .default).async {
                    for message in unreadList {
                        ChatService.shared.setMessageRead(chatId: chat.id, messageId: message.id)
                    }
                }
            }
            return
        }
        
        let vc = ChatViewController()
        _ = vc.view
        vc.setup(chat: chat)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createGroup() {
        let vc = RequestFormGroupViewController()
        _ = vc.view
        vc.setup(for: filteredActivePosts.filter { $0.chat == nil })
        vc.formGroup = { [weak self] post, users in
            self?.dismiss(animated: true, completion: {
                guard let me = ProfileService.shared.profile?.shortUser else { return }
                self?.showLoading()
                
                ExperienceService.shared.acceptRequests(post: post, users: users, complete: {
                    var members = users
                    members.append(me)
                    
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
                                
                                // announce message
                                let msgId = "\(me.id.hashValue)-\(Date().hashValue)"
                                let msg = Message(id: msgId, createdAt: Date(), sender: me, type: .created, text: "\(me.name) created the group", deliveredAt: nil, readAt: nil)
                                ChatService.shared.sendMessage(chatId: chatId, message: msg)
                            }
                        }
                    }
                })
            })
        }
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    //  MARK: - tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if filteredActivePosts.count > 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredActivePosts.count > 0 {
            switch section {
            case 1:
                return filteredChats.count
            default:
                return 1
            }
        }
        return filteredChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if filteredActivePosts.count > 0 && indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: activeCell, for: indexPath) as? ActiveRequestsTableViewCell {
                cell.setup(for: filteredActivePosts)
                
                cell.requestTap = { [weak self] post, request in
                    if let request = request,
                        let chat = self?.chats.first(where: { !($0.type == .group) && $0.members.count == 2 && $0.other().id == request.creator.id }) {
                        self?.open(chat: chat)
                    } else if let chatRef = post.chat,
                        let chat = self?.chats.first(where: { $0.id == chatRef.id }) {
                        self?.open(chat: chat)
                    } else if let chat = self?.chats.first(where: { !($0.type == .group) && $0.members.count == 2 && $0.other().id == post.creator.id }) {
                        self?.open(chat: chat)
                    }
                }
                
                cell.addGroupTap = { [weak self] in
                    self?.createGroup()
                }
                
                return cell
            }
        } else {
            let chat = filteredChats[indexPath.row]
            if chat.members.count > 2 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: groupCell, for: indexPath) as? GroupRequestTableViewCell {
                    cell.setup(for: chat)
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: singleCell, for: indexPath) as? RequestsViewTableViewCell {
                    cell.setup(for: chat)
                    return cell
                }
            }
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (filteredActivePosts.count > 0 && indexPath.section == 1) ||
            (filteredActivePosts.count == 0 && indexPath.section == 0) {
            
            let chat = filteredChats[indexPath.row]
            open(chat: chat)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Gotham-Bold", size: 18)
        label.textColor = .charcoalGrey
        
        header.addSubview(label)
        label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20).isActive = true
        label.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        
        if filteredActivePosts.count > 0 && section == 0 {
            label.text = "Now"
        } else {
            label.text = "Messages"
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        80
    }
    
    // MARK: - no sticky headers
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let sectionHeaderHeight: CGFloat = 80
        if scrollView.contentOffset.y <= sectionHeaderHeight &&
           scrollView.contentOffset.y >= 0 {
           scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else if scrollView.contentOffset.y >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
        }
    }
}
