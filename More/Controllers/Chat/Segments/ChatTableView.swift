//
//  ChatTableView.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import AVKit
import ImageViewer
import SDWebImage

private let requestCell = String(describing: ChatRequestCell.self)
private let incomingCell = String(describing: ChatIncomingCell.self)
private let outgoingCell = String(describing: ChatOutgoingCell.self)
private let responseCell = String(describing: ChatResponseCell.self)
private let typingCell = String(describing: ChatTypingCell.self)
private let dateCell = String(describing: ChatDateCell.self)
private let meetingCell = String(describing: ChatMeetingCell.self)
private let videoCell = String(describing: ChatVideoCell.self)
private let incomingPhotoCell = String(describing: ChatIncomingPhotoCell.self)
private let incomingVideoCell = String(describing: ChatIncomingVideoCell.self)
private let outgoingPhotoCell = String(describing: ChatOutgoingPhotoCell.self)
private let outgoingVideoCell = String(describing: ChatOutgoingVideoCell.self)
private let userInfoCell = String(describing: ChatUserInfoCell.self)
private let infoCell = String(describing: ChatInfoCell.self)

private extension MessageViewModel {
    var fromMe: Bool {
        return sender.id == ProfileService.shared.profile?.id
    }
}

class ChatCell: Hashable {
    
    enum ChatCellType {
        case message, typing, date
    }
    
    let type: ChatCellType
    let message: Message?
    let date: Date?
    
    init(type: ChatCellType, message: Message? = nil, date: Date? = nil) {
        self.type = type
        self.message = message
        self.date = date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        if let message = message {
            hasher.combine(message.id)
        }
    }
    
    static func == (lhs: ChatCell, rhs: ChatCell) -> Bool {
        if lhs.type == rhs.type {
            if lhs.type == .message {
                return lhs.message == rhs.message
            }
            if lhs.type == .date {
                return lhs.date == rhs.date
            }
            return true
        }
        return false
    }
    
    var createdAt: Date {
        return message?.createdAt ?? date ??  Date(timeIntervalSinceNow: 3.154e+7)
    }
}

class ChatTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    private var rows: [ChatCell] = []
    
    private var isAnimating = false
    private var buffer: [ChatCell]? = nil
    
    var chat: Chat?
    
    var showTyping: Bool = false {
        didSet {
            if !isAnimating {
                setup(for: rows.filter { $0.type == .message })
            }
        }
    }
    
    var showProfile: ((_ user: ShortUser)->())?
    
    var showExperience: ((_ experienceId: String)->())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    private func setup() {
        
        contentInsetAdjustmentBehavior = .never
        insetsContentViewsToSafeArea = false
        // estimatedRowHeight = UITableViewDelegate. automatic
        estimatedSectionFooterHeight = 0
        estimatedSectionHeaderHeight = 0
        keyboardDismissMode = .onDrag
        
        register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        register(UINib(nibName: requestCell, bundle: nil), forCellReuseIdentifier: requestCell)
        register(UINib(nibName: incomingCell, bundle: nil), forCellReuseIdentifier: incomingCell)
        register(UINib(nibName: outgoingCell, bundle: nil), forCellReuseIdentifier: outgoingCell)
        register(UINib(nibName: responseCell, bundle: nil), forCellReuseIdentifier: responseCell)
        register(UINib(nibName: typingCell, bundle: nil), forCellReuseIdentifier: typingCell)
        register(UINib(nibName: dateCell, bundle: nil), forCellReuseIdentifier: dateCell)
        register(UINib(nibName: meetingCell, bundle: nil), forCellReuseIdentifier: meetingCell)
        register(UINib(nibName: videoCell, bundle: nil), forCellReuseIdentifier: videoCell)
        register(UINib(nibName: incomingPhotoCell, bundle: nil), forCellReuseIdentifier: incomingPhotoCell)
        register(UINib(nibName: incomingVideoCell, bundle: nil), forCellReuseIdentifier: incomingVideoCell)
        register(UINib(nibName: outgoingPhotoCell, bundle: nil), forCellReuseIdentifier: outgoingPhotoCell)
        register(UINib(nibName: outgoingVideoCell, bundle: nil), forCellReuseIdentifier: outgoingVideoCell)
        register(UINib(nibName: userInfoCell, bundle: nil), forCellReuseIdentifier: userInfoCell)
        register(UINib(nibName: infoCell, bundle: nil), forCellReuseIdentifier: infoCell)
        
        dataSource = self
        delegate = self
    }
    
    func setup(for rows: [ChatCell], forceScrollToBotton: Bool = false, insertAnimation: UITableView.RowAnimation = .left) {
        
        guard isAnimating == false else {
            buffer = rows
            return
        }
        
        // sorting
        var sortedRows = rows.sorted { (lhs, rhs) -> Bool in
            return lhs.createdAt < rhs.createdAt
        }
        
        // date cells
        let calendar = Calendar.current
        for (idx, row) in sortedRows.enumerated().reversed() {
            if idx == 0 {
                sortedRows.insert(ChatCell(type: .date, date: row.createdAt), at: 0)
            } else {
                let previous = sortedRows[idx - 1]
                if !calendar.isDate(row.createdAt, inSameDayAs: previous.createdAt) {
                    sortedRows.insert(ChatCell(type: .date, date: row.createdAt), at: idx)
                }
            }
        }
        
        // typing
        if showTyping {
            sortedRows.append(ChatCell(type: .typing))
        }
        
        // get old rows maping
        var oldRows: [ChatCell: Int] = [:]
        for (idx, row) in self.rows.enumerated() {
            oldRows[row] = idx
        }
        
        // get new rows mapping
        var newRows: [ChatCell: Int] = [:]
        for (idx, row) in sortedRows.enumerated() {
            newRows[row] = idx
        }
        
        var moved: [(Int, Int)] = []
        var reloaded: [Int] = []
        var deleted: [Int] = []
        var inserted: [Int] = []
        
        // moved, reloaded & deleted
        for old in self.rows {
            if let oldIdx = oldRows[old] {
                if let newIdx = newRows[old] {
                    if newIdx != oldIdx {
                        let pair = (min(oldIdx, newIdx), max(oldIdx, newIdx))
                        if !moved.contains(where: { (p) in p.0 == pair.0 && p.1 == pair.1 }) {
                            moved.append(pair)
                        }
                    } else {
                        if let oldMsg = old.message,
                            let newMsg = sortedRows.first(where: { $0.message?.id == oldMsg.id })?.message {
                            
                            var oldReadAt: [String] = []
                            if let keys = oldMsg.readAt?.keys {
                                oldReadAt = Array(keys).sorted()
                            }
                            var newReadAt: [String] = []
                            if let keys = newMsg.readAt?.keys {
                                newReadAt = Array(keys).sorted()
                            }
                            var oldDeliveredAt: [String] = []
                            if let keys = oldMsg.deliveredAt?.keys {
                                oldDeliveredAt = Array(keys).sorted()
                            }
                            var newDeliveredAt: [String] = []
                            if let keys = newMsg.deliveredAt?.keys {
                                newDeliveredAt = Array(keys).sorted()
                            }
                            
                            if !oldReadAt.elementsEqual(newReadAt) ||
                                !oldDeliveredAt.elementsEqual(newDeliveredAt) ||
                                oldMsg.text != newMsg.text {
                                reloaded.append(oldIdx)
                            }
                        }
                    }
                } else {
                    deleted.append(oldIdx)
                }
            }
        }
        
        // inserted
        for new in sortedRows {
            if let newIdx = newRows[new] {
                if oldRows[new] == nil {
                    inserted.append(newIdx)
                }
            }
        }
        
        let lastIndex = IndexPath(row: self.rows.count - 1, section: 0)
        let scroll = indexPathsForVisibleRows?.contains(lastIndex) == true
        
        self.rows = sortedRows
        
        beginUpdates()
        if deleted.count > 0 {
            deleteRows(at: deleted.map { IndexPath(row: $0, section: 0) }, with: .fade)
        }
        if inserted.count > 0 {
            insertRows(at: inserted.map { IndexPath(row: $0, section: 0) }, with: insertAnimation)
        }
        for row in moved {
            moveRow(at: IndexPath(row: row.0, section: 0), to: IndexPath(row: row.1, section: 0))
        }
        if reloaded.count > 0 {
            reloadRows(at: reloaded.map { IndexPath(row: $0, section: 0) }, with: .none)
        }
        endUpdates()
        
//        performBatchUpdates({
//            if reloaded.count > 0 {
//                reloadRows(at: reloaded.map { IndexPath(row: $0, section: 0) }, with: .none)
//            }
//            if moved.count > 0 {
//                moveRow(at: moved.map { IndexPath(row: $0.0, section: 0) }, to: moved.map { IndexPath(row: $0.1, section: 0) })
//            }
//            if deleted.count > 0 {
//                deleteRows(at: deleted.map { IndexPath(row: $0, section: 0) }, with: .fade)
//            }
//            if inserted.count > 0 {
//                insertRows(at: inserted.map { IndexPath(row: $0, section: 0) }, with: insertAnimation)
//            }
//        }, completion: nil)
        
        if scroll || forceScrollToBotton {
            scrollToBottom()
        } else {
            animationStarted()
        }
    }
    
    func scrollToBottom() {
        guard rows.count > 0 else { return }
        scrollToRow(at: IndexPath(row: rows.count - 1, section: 0), at: .bottom, animated: true)
        animationStarted()
    }
    
    private func animationStarted() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.animationEnded()
        }
    }
    
    private func animationEnded() {
        isAnimating = false
        if let buffer = buffer {
            self.buffer = nil
            setup(for: buffer)
        }
    }
    
    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowModel = rows[indexPath.row]
        switch rowModel.type {
        case .typing:
            if let cell = tableView.dequeueReusableCell(withIdentifier: typingCell, for: indexPath) as? ChatTypingCell {
                return cell
            }
        case .date:
            if let date = rowModel.date,
                let cell = tableView.dequeueReusableCell(withIdentifier: dateCell, for: indexPath) as? ChatDateCell {
                cell.setup(for: date)
                return cell
            }
        case .message:
            if let message = rowModel.message, let chat = chat {
                switch message.type {
                case .request:
                    var identifier = requestCell
                    if let post = Chat.getPost(for: chat), post.chat?.id == chat.id {
                        identifier = userInfoCell
                    }
                    if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ChatRequestCell {
                        cell.setup(for: message, in: chat)
                        return cell
                    }
                case .accepted, .expired:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: responseCell, for: indexPath) as? ChatResponseCell {
                        cell.setup(for: message, in: chat)
                        return cell
                    }
                case .text:
                    let identifier = message.sender.isMe() ? outgoingCell : incomingCell
                    if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ChatBaseCell {
                        cell.setup(for: message, in: chat)
                        return cell
                    }
                case .meeting:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: meetingCell, for: indexPath) as? ChatBaseCell {
                        cell.setup(for: message, in: chat)
                        return cell
                    }
                case .welcome:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: videoCell, for: indexPath) as? ChatBaseCell {
                        cell.setup(for: message, in: chat)
                        return cell
                    }
                case .photo:
                    let identifier = message.sender.isMe() ? outgoingPhotoCell : incomingPhotoCell
                    if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ChatBaseCell {
                        cell.setup(for: message, in: chat)
                        return cell
                    }
                case .video:
                    let identifier = message.sender.isMe() ? outgoingVideoCell : incomingVideoCell
                    if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ChatBaseCell {
                        cell.setup(for: message, in: chat)
                        return cell
                    }
                case .met, .joined, .startCall:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: userInfoCell, for: indexPath) as? ChatBaseCell {
                        cell.setup(for: message, in: chat)
                        return cell
                    }
                case .created:
                    if message.additionalVirtualTimeId() != nil {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: infoCell, for: indexPath) as? ChatBaseCell {
                            cell.setup(for: message, in: chat)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: userInfoCell, for: indexPath) as? ChatBaseCell {
                            cell.setup(for: message, in: chat)
                            return cell
                        }
                    }
                    
                default: ()
                }
            }
        }
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rowModel = rows[indexPath.row]
        if rowModel.type == .message, let message = rowModel.message {
            
            if message.type == .video {
                guard let urlStr = message.additionalUrl(), let url = URL(string: urlStr) else { return }
                let vc = AVPlayerViewController()
                vc.player = AVPlayer(url: url)
                AppDelegate.appDelegate()?.window?.rootViewController?.present(vc, animated: true, completion: nil)
            } else if message.type == .photo {
                guard let urlStr = message.additionalUrl(), let url = URL(string: urlStr) else { return }
                showImage(url)
            } else if message.type == .joined || message.type == .request || message.type == .startCall {
                guard let me = ProfileService.shared.profile, me.id != message.sender.id else { return }
                showProfile?(message.sender)
            } else if message.type == .created {
                if let experienceId = message.additionalVirtualTimeId() {
                    showExperience?(experienceId)
                } else {
                    showProfile?(message.sender)
                }
            }
        }
    }
    
    
    // MARK: - handle messages
    
    func newMessage(_ message: Message) {
        let cellModel = ChatCell(type: .message, message: message)
        if isAnimating {
            buffer?.append(cellModel)
            return
        }
        
        var newRows = rows.filter { $0.type == .message }
        newRows.append(cellModel)
        setup(for: newRows, forceScrollToBotton: true, insertAnimation: .right)
    }
    
    fileprivate var item: GalleryItem?
}

// MARK: - image viewer

extension ChatTableView: GalleryItemsDataSource {
    
    private func showImage(_ url: URL) {
        
        item =
        GalleryItem.image { (finished) in
            SDWebImageDownloader.shared.downloadImage(
                with: url,
                options: .highPriority,
                progress: nil,
                completed: { (photo, _, _, _) in
                    if let photo = photo {
                        finished(photo)
                    }
            })
        }
        
        let gallery = GalleryViewController(
            startIndex: 0,
            itemsDataSource: self,
            configuration: galleryConfiguration())
        
        AppDelegate.appDelegate()?.window?.rootViewController?.presentImageGallery(gallery)
    }
    
    func itemCount() -> Int {
        return 1
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        if let item = item {
            return item
        }
        
        return GalleryItem.image { (finished) in finished(UIImage()) }
    }
    
    func galleryConfiguration() -> GalleryConfiguration {
        
        return [
            
            GalleryConfigurationItem.closeButtonMode(.builtIn),
            
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.fade),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            
            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),
            GalleryConfigurationItem.activityViewByLongPress(false),
            
            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffect.Style.light),
            
            GalleryConfigurationItem.videoControlsColor(.white),
            
            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),
            
            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),
            
            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),
            
            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),
            
            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),
            
            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),
            
            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50),
            
            GalleryConfigurationItem.deleteButtonMode(.none),
            GalleryConfigurationItem.seeAllCloseButtonMode(.none),
            GalleryConfigurationItem.thumbnailsButtonMode(.none),
        ]
    }
}

