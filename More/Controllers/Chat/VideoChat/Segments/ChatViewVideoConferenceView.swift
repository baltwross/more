//
//  ChatViewVideoConferenceView.swift
//  More
//
//  Created by Luko Gjenero on 08/04/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit
import TwilioVideo

private let cellIdentifier = "Cell"
private let spacing: CGFloat = 0
private let messageTag = 12341234

@IBDesignable
class ChatViewVideoConferenceView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var chat: Chat?
    
    private let grid: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = .zero
        let grid = UICollectionView(frame: .zero, collectionViewLayout: layout)
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.backgroundColor = .black
        return grid
    }()
    
    private let fullView: ChatViewVideoView = {
        let fullView = ChatViewVideoView()
        fullView.translatesAutoresizingMaskIntoConstraints = false
        fullView.backgroundColor = .clear
        fullView.layer.masksToBounds = true
        return fullView
    }()
    
    private let myView: ChatViewVideoView = {
        let myView = ChatViewVideoView()
        myView.translatesAutoresizingMaskIntoConstraints = false
        myView.backgroundColor = .clear
        myView.enableCardShadow(color: .black)
        return myView
    }()
    
    private let blockView: UIView = {
        let blockView = UIView()
        blockView.translatesAutoresizingMaskIntoConstraints = false
        blockView.backgroundColor = .black
        return blockView
    }()
    
    private var fullLeading: NSLayoutConstraint!
    private var fullTrailing: NSLayoutConstraint!
    private var fullTop: NSLayoutConstraint!
    private var fullBottom: NSLayoutConstraint!
    
    private var myTop: NSLayoutConstraint!
    private var myTrailing: NSLayoutConstraint!
    private var myWidth: NSLayoutConstraint!
    private var myHeight: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var expanded: ((_ user: ShortUser)->())?
    var collapsed: (()->())?
    var audio: (()->())?
    var restore: (()->())?
    
    var isExpanded: Bool {
        return !fullView.isHidden
    }
    
    var isMinimized: Bool {
        return fullView.isHidden && grid.isHidden && !myView.isHidden
    }
    
    private func setup() {
        
        self.backgroundColor = .clear
        
        grid.contentInsetAdjustmentBehavior = .never
        
        addSubview(grid)
        addSubview(fullView)
        addSubview(myView)
        addSubview(blockView)
        
        grid.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        grid.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        grid.topAnchor.constraint(equalTo: topAnchor).isActive = true
        grid.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        fullLeading = fullView.leadingAnchor.constraint(equalTo: leadingAnchor); fullLeading.isActive = true
        fullTrailing = fullView.trailingAnchor.constraint(equalTo: trailingAnchor); fullTrailing.isActive = true
        fullTop = fullView.topAnchor.constraint(equalTo: topAnchor); fullTop.isActive = true
        fullBottom = fullView.bottomAnchor.constraint(equalTo: bottomAnchor); fullBottom.isActive = true
        
        myTop = myView.topAnchor.constraint(equalTo: topAnchor); myTop.isActive = true
        myTrailing = myView.trailingAnchor.constraint(equalTo: trailingAnchor); myTrailing.isActive = true
        myWidth = myView.widthAnchor.constraint(equalToConstant: 100); myWidth.isActive = true
        myHeight = myView.heightAnchor.constraint(equalToConstant: 133); myHeight.isActive = true
        
        blockView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blockView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blockView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blockView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        grid.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        grid.register(Cell.self, forCellWithReuseIdentifier: cellIdentifier)
        grid.dataSource = self
        grid.delegate = self
        
        fullView.isHidden = true
        myView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatChanged(_:)), name: ChatService.Notifications.ChatChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraChanged(_:)), name: VideoCallService.Notifications.CameraChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(membersChanged(_:)), name: VideoCallService.Notifications.MembersChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged(_:)), name: VideoCallService.Notifications.VideoSettingsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(preventScreenRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
        
        fullView.tap = { [weak self] in
            self?.collapse()
        }
        
        fullView.doubleTap = { [weak self] in
            self?.fullView.toggleVideo()
        }
        
        myView.audioTap = { [weak self] in
            self?.audio?()
        }
        
        myView.tap = { [weak self] in
            if self?.isMinimized == true {
                self?.restore?()
            }
        }
        
        preventScreenRecording()
    }
    
    @objc private func chatChanged(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let chat =  notice.userInfo?["chat"] as? Chat, self?.chat?.id == chat.id else { return }
            self?.chatUpdated(chat)
        }
    }
    
    @objc private func cameraChanged(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let sself = self else { return }
            guard let me = ProfileService.shared.profile else { return }
            guard let videoCall = sself.chat?.videoCall else { return }
            
            let shouldMirror = VideoCallService.shared.videoTrack?.shouldMirror ?? false
            if !sself.fullView.isHidden && sself.fullView.user?.id == me.id {
                sself.fullView.updateMirror(shouldMirror)
            }
            if !sself.myView.isHidden {
                sself.myView.updateMirror(shouldMirror)
            }
            
            if let idx = videoCall.sortedMembers().firstIndex(of: me.shortUser),
                let cell = sself.grid.cellForItem(at: IndexPath(item: idx, section: 0)) as? Cell {
                cell.updateMirror(shouldMirror)
            }
        }
    }
    
    @objc private func settingsChanged(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let sself = self else { return }
            guard let me = ProfileService.shared.profile else { return }
            guard let videoCall = sself.chat?.videoCall else { return }

            if !sself.fullView.isHidden && sself.fullView.user?.id == me.id {
                sself.fullView.setupVideoForMe()
            }
            if !sself.myView.isHidden {
                sself.myView.setupVideoForMe()
            }
            
            if let idx = videoCall.sortedMembers().firstIndex(of: me.shortUser),
                let cell = sself.grid.cellForItem(at: IndexPath(item: idx, section: 0)) as? Cell {
                cell.setupForMe()
            }
        }
    }
    
    @objc private func membersChanged(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.grid.reloadData()
            
            // full view
            if self?.fullView.isHidden == false, let member = self?.fullView.user {
                guard let me = ProfileService.shared.profile else { return }

                self?.fullView.setup(for: member)
                if member.id == me.id {
                    self?.fullView.setupVideoForMe()
                } else {
                    let participant = VideoCallService.shared.getParticipants().first(where: { $0.identity == member.id })
                    self?.fullView.setupVideo(for: participant)
                }
            }
        }
    }
    
    @objc private func preventScreenRecording() {
        let isCaptured = UIScreen.main.isCaptured
        if isCaptured {
            self.blockView.isHidden = false;
        }
        else {
            self.blockView.isHidden = true;
        }
    }
    
    private var lastSize: CGSize = .zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !frame.size.equalTo(lastSize) {
            lastSize = frame.size
            grid.collectionViewLayout.invalidateLayout()
            grid.reloadData()
        }
    }
    
    func setup(for chat: Chat) {
        self.chat = chat
        grid.reloadData()
    }
    
    private func chatUpdated(_ chat: Chat) {
        guard let oldCall = self.chat?.videoCall else {
            setup(for: chat)
            return
        }
        
        let oldMembers = oldCall.members.map { $0.id }.sorted()
        let newMembers = chat.videoCall?.members.map { $0.id }.sorted() ?? []
        
        if !(oldMembers.count == newMembers.count && oldMembers == newMembers) {
            setup(for: chat)
            
            if oldMembers.count < newMembers.count,
                let joinedId = newMembers.first(where: { !oldMembers.contains($0) }),
                let joined = chat.videoCall?.members.first(where: { $0.id == joinedId}) {
                showCenterMessage("\(joined.name) joined")
            } else if oldMembers.count > newMembers.count,
                let leftId = oldMembers.first(where: { !newMembers.contains($0) }),
                let left = oldCall.members.first(where: { $0.id == leftId}) {
                showCenterMessage("\(left.name) left")
            }
        }
    }
    
    private func showCenterMessage(_ message: String) {
        
        viewWithTag(messageTag)?.removeFromSuperview()
        
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.backgroundColor = .clear
        blurView.layer.cornerRadius = 18
        blurView.layer.masksToBounds = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tag = messageTag
        label.backgroundColor = .clear
        label.textColor = .charcoalGrey
        label.font = UIFont(name: "Gotham-Medium", size: 13)
        label.text = "   \(message)   "
        
        blurView.contentView.addSubview(label)
        label.heightAnchor.constraint(equalToConstant: 36).isActive = true
        label.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: blurView.contentView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor).isActive = true
        
        addSubview(blurView)
        blurView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        blurView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak blurView] in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    blurView?.alpha = 0
                },
                completion: { _ in
                    blurView?.removeFromSuperview()
                })
        }
    }
    
    // MARK: - datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chat?.videoCall?.members.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let me = ProfileService.shared.profile,
            let member = chat?.videoCall?.sortedMembers()[indexPath.item],
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? Cell {
            
            if member.id == me.id {
                cell.setupForMe()
            } else {
                let participant = VideoCallService.shared.getParticipants().first(where: { $0.identity == member.id })
                cell.setup(member: member, participant: participant)
            }
            cell.tap = { [weak self] in
                self?.expand(member: member)
            }
            cell.doubleTap = { [weak cell] in
                cell?.toggleVideo()
            }
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // TODO: selection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let num = collectionView.numberOfItems(inSection: 0)
        let item = indexPath.item
        let size = collectionView.frame.size
        switch num {
        case 1:
            return size
        case 2:
            return CGSize(width: size.width, height: height(item, of: 2))
        case 3:
            return CGSize(width: size.width, height: height(item, of: 3))
        case 4:
            return CGSize(width: width(item % 2, of: 2), height: height(item / 2, of: 2))
        case 5,6:
            if num == 6 || item < 4 {
                return CGSize(width: width(item % 2, of: 2), height: height(item / 3, of: 3))
            } else {
                return CGSize(width: size.width, height: height(2, of: 3))
            }
        case 7,8:
            if num == 8 || item < 6 {
                return CGSize(width: width(item % 2, of: 2), height: height(item / 4, of: 4))
            } else {
                return CGSize(width: size.width, height: height(3, of: 4))
            }
        case 9:
            return CGSize(width: width(item % 3, of: 3), height: height(item / 3, of: 3))
        case 10,11:
            if  item == 9 && num == 10 {
                return CGSize(width: size.width, height: height(3, of: 4))
            } else if (item == 9 || item == 10) && num == 11 {
                return CGSize(width: width(1 - (item % 2), of: 2), height: height(3, of: 4))
            }
            return CGSize(width: width(item % 3, of: 3), height: height(item / 4, of: 4))
        default: // 12
            return CGSize(width: width(item % 3, of: 3), height: height(item / 4, of: 4))
        }
    }
    
    // MARK: - cell sizing
    
    func width(_ idx: Int, of count: Int) -> CGFloat {
        let correctedWidth = grid.frame.width - CGFloat(count - 1) * spacing
        let minWidth = floor(correctedWidth / CGFloat(count))
        let rest = correctedWidth - CGFloat(count) * minWidth
        
        if idx >= Int(rest) {
            return minWidth
        }
        return minWidth + 1
    }
    
    func height(_ idx: Int, of count: Int) -> CGFloat {
        let correctedHeight = grid.frame.height - CGFloat(count - 1) * spacing
        let minHeight = floor(correctedHeight / CGFloat(count))
        let rest = correctedHeight - CGFloat(count) * minHeight
        
        if idx >= Int(rest) {
            return minHeight
        }
        return minHeight + 1
    }
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        var tap: (()->())?
        var doubleTap: (()->())?
        
        private let content: ChatViewVideoView = {
            let content = ChatViewVideoView()
            content.translatesAutoresizingMaskIntoConstraints = false
            content.backgroundColor = .clear
            return content
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(content)
            
            content.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            
            contentView.setNeedsLayout()
            
            content.tap = { [weak self] in
                self?.tap?()
            }
            content.doubleTap = { [weak self] in
                self?.doubleTap?()
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setup(member: ShortUser, participant: RemoteParticipant?) {
            content.setup(for: member)
            content.setupVideo(for: participant)
        }
        
        func setupForMe() {
            guard let me = ProfileService.shared.profile else { return }
            content.setup(for: me.shortUser)
            content.setupVideoForMe()
        }
        
        func toggleVideo() {
            content.toggleVideo()
        }
        
        func updateMirror(_ shouldMirror: Bool) {
            content.updateMirror(shouldMirror)
        }
        
        func updateVideo(_ videoEnabled: Bool) {
            content.updateVideo(videoEnabled)
        }
    }
    
    // MARK: - expand / collapse
    
    func expand(member: ShortUser, animated: Bool = true) {
        guard let me = ProfileService.shared.profile else { return }
        guard let videoCall = chat?.videoCall else { return }
        guard let index = videoCall.sortedMembers().firstIndex(of: member) else { return }
        guard let cell = grid.cellForItem(at: IndexPath(item: index, section: 0)) else { return }
        
        // full view
        let cellFrame = cell.convert(cell.bounds, to: self)
        collapseFullView(to: cellFrame)
        fullView.isHidden = false
        
        fullView.setup(for: member)
        if member.id == me.id {
            fullView.setupVideoForMe()
        } else {
            let participant = VideoCallService.shared.getParticipants().first(where: { $0.identity == member.id })
            fullView.setupVideo(for: participant)
        }
        
        // my view
        var myCell: UICollectionViewCell? = nil
        if let myIndex = videoCall.sortedMembers().firstIndex(of: me.shortUser), myIndex != index,
            let cell = grid.cellForItem(at: IndexPath(item: myIndex, section: 0)) {
            myCell = cell
        }
        if let myCell = myCell {
            let myCellFrame = myCell.convert(myCell.bounds, to: self)
            collapseMyView(to: myCellFrame)
            myView.isHidden = false
            
            myView.setup(for: me.shortUser)
            myView.setupVideoForMe(showAudio: true)
        }
        layoutIfNeeded()
        
        // Animate
        UIView.animate(
            withDuration: 0.4,
            animations: { [weak self] in
                self?.expandFullView()
                if myCell != nil {
                    self?.expandMyView()
                }
                self?.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                self?.grid.isHidden = true
            })
        
        expanded?(member)
    }
    
    func collapse() {
        
        grid.isHidden = false
        
        guard let user = fullView.user,
            let me = ProfileService.shared.profile,
            let videoCall = chat?.videoCall,
            let index = videoCall.sortedMembers().firstIndex(of: user),
            let cell = grid.cellForItem(at: IndexPath(item: index, section: 0))
            else {
            fullView.isHidden = true
            myView.isHidden = true
            return
        }
        
        let cellFrame = cell.convert(cell.bounds, to: self)
        fullView.isHidden = false
        expandFullView()
        
        var myCellFrame: CGRect? = nil
        if let myIndex = videoCall.sortedMembers().firstIndex(of: me.shortUser), myIndex != index,
            let cell = grid.cellForItem(at: IndexPath(item: myIndex, section: 0)) {
            myCellFrame = cell.convert(cell.bounds, to: self)
        }
        myView.isHidden = true
        if myCellFrame != nil {
            expandMyView()
            myView.isHidden = false
        }
        layoutIfNeeded()
        
        // Animate
        UIView.animate(
            withDuration: 0.4,
            animations: { [weak self] in
                self?.collapseFullView(to: cellFrame)
                if let myCellFrame = myCellFrame {
                    self?.collapseMyView(to: myCellFrame)
                }
                self?.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                self?.fullView.isHidden = true
                self?.myView.isHidden = true
            })
        collapsed?()
    }
    
    func switchToMini() {
        guard let me = ProfileService.shared.profile else { return }
        guard let videoCall = chat?.videoCall else { return }
        
        // my view
        var myCell: UICollectionViewCell? = nil
        if myView.isHidden {
            if let myIndex = videoCall.sortedMembers().firstIndex(of: me.shortUser),
                let cell = grid.cellForItem(at: IndexPath(item: myIndex, section: 0)) {
                myCell = cell
            }
            if let myCell = myCell {
                let myCellFrame = myCell.convert(myCell.bounds, to: self)
                collapseMyView(to: myCellFrame)
                myView.isHidden = false
                
                myView.setup(for: me.shortUser)
                myView.setupVideoForMe(showAudio: true)
            }
            layoutIfNeeded()
        }
        
        
        // Animate
        let translation = CATransform3DMakeTranslation(0, frame.height, 0)
        UIView.animate(
            withDuration: 0.4,
            animations: { [weak self] in
                self?.fullView.alpha = 0
                self?.fullView.layer.transform = translation
                self?.grid.layer.transform = translation
                
                if myCell != nil {
                    self?.expandMyView()
                }
                self?.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                self?.grid.isHidden = true
            })
    }
    
    func switchBackFromMini() {
        guard let me = ProfileService.shared.profile else { return }
        guard let videoCall = chat?.videoCall else { return }
        
        grid.isHidden = false
        
        // my view
        var myCellFrame: CGRect? = nil
        if fullView.isHidden || fullView.user?.id != me.id {
            if let myIndex = videoCall.sortedMembers().firstIndex(of: me.shortUser),
                let cell = grid.cellForItem(at: IndexPath(item: myIndex, section: 0)) {
                myCellFrame = cell.convert(cell.bounds, to: self)
            }
        }
        
        // Animate
        let translation = CATransform3DIdentity
        UIView.animate(
            withDuration: 0.4,
            animations: { [weak self] in
                self?.fullView.alpha = 1
                self?.fullView.layer.transform = translation
                self?.grid.layer.transform = translation
                
                if let myCellFrame = myCellFrame {
                    self?.collapseMyView(to: myCellFrame)
                    self?.myView.layer.transform = translation
                }
                self?.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                self?.myView.isHidden = true
            })
    }
    
    private func expandFullView() {
        fullLeading.constant = 0
        fullTrailing.constant = 0
        fullTop.constant = 0
        fullBottom.constant = 0
        fullView.userAplha = 0
    }
    
    private func collapseFullView(to frame: CGRect) {
        fullLeading.constant = frame.minX
        fullTrailing.constant = -self.frame.width + frame.maxX
        fullTop.constant = frame.minY
        fullBottom.constant = -self.frame.height + frame.maxY
        fullView.userAplha = 1
    }
    
    private func expandMyView() {
        myTop.constant = 43
        myTrailing.constant = -10
        myWidth.constant = 110
        myHeight.constant = 133
        myView.videoCornerRadius = 15
        myView.audioAplha = 1
    }
    
    private func collapseMyView(to frame: CGRect) {
        myTop.constant = frame.minY
        myTrailing.constant = -self.frame.width + frame.maxX
        myWidth.constant = frame.width
        myHeight.constant = frame.height
        myView.videoCornerRadius = 0
        myView.audioAplha = 0
    }
    
    // MARK: - prep
    
    private(set) var isPrep = true
    
    func showPrep() {
        VideoCallService.shared.prep(enable: true)
        
        // 1. expand my view
        // 2. show counter
        // in 5 secs start
        
        isUserInteractionEnabled = false
        expandMyView()
        
        let prep = ChatViewVideoPrepView()
        prep.translatesAutoresizingMaskIntoConstraints = false
        prep.backgroundColor = .clear
        
        addSubview(prep)
        prep.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        prep.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        prep.countdown(from: 5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak prep, weak self] in
            VideoCallService.shared.prep(enable: false)
            self?.isUserInteractionEnabled = true
            self?.collapse()
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    prep?.alpha = 0
                },
                completion: { _ in
                    prep?.removeFromSuperview()
                    
                })
            }
    }
    
}

extension ChatViewVideoConferenceView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews {
            let insideSubview = !view.isHidden &&
                view.alpha == 1 &&
                view.point(inside: convert(point, to: view), with: event)
            if insideSubview {
                return true
            }
        }
        return false
    }
    
    /*
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit == self {
            return nil
        }
        return hit
    }
    */
}

extension LocalVideoTrack {
    var shouldMirror: Bool {
        guard let source = source as? CameraSource else { return false }
        return source.device?.position == .front
    }
}
