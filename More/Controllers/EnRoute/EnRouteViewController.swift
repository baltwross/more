//
//  EnRouteViewController.swift
//  More
//
//  Created by Luko Gjenero on 09/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import MapKit
import Mapbox
import MapboxDirections
import SDWebImage
import SwiftMessages
import Firebase

class EnRouteViewController: UIViewController {

    @IBOutlet weak var header: EnRouteHeader!
    @IBOutlet weak var mapBox: MGLMapView!
    @IBOutlet weak var destinationView: EnRouteDestinationView!
    @IBOutlet weak var directionsView: EnRouteDirectionsView!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var shieldButton: UIButton!
    @IBOutlet weak var trackingButton: UIButton!
    @IBOutlet weak var tableViewHeader: EnRouteMessagingHeader!
    @IBOutlet weak var tableView: ChatTableView!
    @IBOutlet weak var inputBar: MessagingInputBar!
    @IBOutlet weak var messagingTop: NSLayoutConstraint!
    @IBOutlet weak var resume: UIButton!
    @IBOutlet weak var meetupBar: EnRouteMeetupBar!
    
    // initial overlay
    @IBOutlet private weak var initialOverlay: UIView!
    @IBOutlet private weak var trackingLabel: UILabel!
    @IBOutlet private weak var helpLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var initialOverlayBottom: NSLayoutConstraint!
    
    private var overlays: [UIView] {
        return [initialOverlay, trackingLabel, helpLabel, timeLabel]
    }
    
    
    private var time: ExperienceTime?
    
    private var mapController: EnRouteViewMapController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInsetAdjustmentBehavior = .never
        
        header.profileTap = { [weak self] in
            self?.presentProfile()
        }
        
        header.callTap = { [weak self] in
            // TODO: WEB RTC call
        }
        
        header.messageTap = { [weak self] in
            self?.expandMessageView(fully: false)
        }
        
        tableViewHeader.downTap = { [weak self] in
            self?.inputBar.reset()
            self?.inputBar.hideKeyboard()
            self?.collapseMessageView(fully: true)
        }
        
        inputBar.sendTap = { [weak self] (text) in
            self?.sendMessage(text)
        }
        if let user = ProfileService.shared.profile?.shortUser {
            inputBar.showAvatar = true
            inputBar.setup(for: user)
        }
        
        tableViewHeader.isHidden = true
        tableView.isHidden = true
        
        mapBox.styleURL = URL(string: MapBox.styleUrl)
        
        mapController = EnRouteViewMapController(mapBox: mapBox, tableViewHeader: tableViewHeader, destinationView: destinationView, directionsView: directionsView)
        
        mapController.birdEye = { [weak self] in
            self?.showResume()
        }
        
        let buttons = [trackingButton, shieldButton, timeButton]
        for button in buttons {
            button?.enableShadow(color: .black, path: UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 57, height: 57)).cgPath)
        }
        
        hideWeMet()
        
        track()
        
        for constraint in view.constraints {
            if constraint.firstAnchor == inputBar.bottomAnchor ||
                constraint.secondAnchor == inputBar.bottomAnchor {
                bottomContraint = constraint
                break
            }
        }
        trackKeyboardAndPushUp()
        trackKeyboard(onlyFor: [inputBar.textView])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var isFirst: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        let padding = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - tableViewHeader.frame.height - 72
        messagingTop.constant = padding
        view.layoutIfNeeded()
        
        tableView.isHidden = false

        if time?.isFinished() == true {
            presentCancelledUI()
        } else if time?.state() == .queryArrived {
            presentArrivedUI()
        } else if time?.state() == .queryMet {
            presentMetUI()
        }
    }
    
    func setup(for time: ExperienceTime) {
        self.time = time
        
        if let chat = ChatService.shared.getChat(for: time.chat.memberIds) {
            tableView.chat = chat
            tableView.setup(for: chat.messages?.map { ChatCell(type: .message, message: $0) } ?? [])
        }
        header.setup(for: time)
        tableViewHeader.setup(for: time)
        mapController.setupMap(for: time)
        
        showWeMet()
        presentInitialUI()
        
        stopTrackingTyping()
        trackTyping()
    }
    
    func openMessages() {
        expandMessageView(fully: false)
    }
    
    func isPresentingTime(withId timeId: String) -> Bool {
        return time?.id == timeId
    }
    
    @IBAction private func trackingTouch(_ sender: Any) {
        mapController.trackUser(root: self)
        hideResume()
    }
    
    @IBAction private func shieldTouch(_ sender: Any) {
        presentCancelUI()
    }
    
    @IBAction private func timesTouch(_ sender: Any) {
        presentSignal()
    }
    
    @IBAction private func weMetTouch(_ sender: Any) {
        if time?.state() == .queryArrived {
            presentArrivedUI()
        } else if time?.state() == .queryMet {
            presentMetUI()
        }
    }
    
    @IBAction func resumeTouch(_ sender: Any) {
        mapController.trackUser()
        hideResume()
    }
    
    // MARK: - tracking
    
    private func track() {
        NotificationCenter.default.addObserver(self, selector: #selector(timeStateChanged(_:)), name: TimesService.Notifications.TimeStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timeExpired(_:)), name: TimesService.Notifications.TimeExpired, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMessage(_:)), name: ChatService.Notifications.ChatsLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newMessage(_:)), name: ChatService.Notifications.ChatMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(typing(_:)), name: ChatService.Notifications.ChatTyping, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func newMessage(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let time = self?.time else { return }
            guard let chat = ChatService.shared.getChats().first(where: { $0.other().id == time.otherPerson().id }) else { return }
            
            self?.tableView.chat = chat
            self?.tableView.setup(for: chat.messages?.map { ChatCell(type: .message, message: $0) } ?? [])
            
            let msgs = chat.messages?.filter { !$0.isMine() && $0.readAt == nil } ?? []
            
            if self?.messageingExpanded == false {
                self?.unreadMessages = msgs.count
                self?.header.setupForMessages(highlight: true, count: self?.unreadMessages ?? 0)
            } else {
                DispatchQueue.global(qos: .default).async {
                    for msg in msgs {
                        ChatService.shared.setMessageRead(chatId: chat.id, messageId: msg.id)
                    }
                }
            }
        }
    }
    
    @objc private func typing(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let time = self?.time else { return }
            guard let chat = ChatService.shared.getChats().first(where: { $0.other().id == time.otherPerson().id }) else { return }
            
            guard chat.id == notice.userInfo?["chatId"] as? String,
                time.otherPerson().id == notice.userInfo?["userId"] as? String,
                let typing = notice.userInfo?["typing"] as? Bool
                else { return }
            
            self?.tableView.showTyping = typing
        }
    }
    
    @objc private func timeStateChanged(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let time = notice.userInfo?["time"] as? Time, time.id == self?.time?.id {
                self?.processNotices(for: time)
                self?.header.setupTitle(for: time)
                
                self?.time = time
                if time.otherState() == .cancelled {
                    self?.presentCancelledUI()
                } else if time.otherState() == .met {
                    if time.state() == .met {
                        guard let presenter = self?.presentingViewController as? MoreTabBarNestedNavigationController else { return }
                        presenter.dismiss(animated: true, completion: nil)
                    } else {
                        self?.presentMetUI()
                    }
                } else if time.state() == .queryArrived {
                    self?.presentArrivedUI()
                } else if time.state() == .queryMet {
                    self?.presentMetUI()
                } else if time.state() == .met {
                    self?.showWeMet()
                } else if time.state() == .closed {
                    guard let presenter = self?.presentingViewController as? MoreTabBarNestedNavigationController else { return }
                    presenter.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func timeExpired(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let timeId = notice.userInfo?["timeId"] as? String, timeId == self?.time?.id {
                
                // TODO - expiration ??
                
            }
        }
    }
    
    // MARK: - notices
    
    private func processNotices(for time: Time) {
        guard let old = self.time else { return }

        if old.otherState() != .arrived && time.otherState() == .arrived {
            if old.state() == .arrived {
                presentNotice(photo: time.otherPerson().avatar, text: "\(time.otherPerson().name) is nearby! Confirm in the app when you find each other.")
            } else {
                presentNotice(photo: time.otherPerson().avatar, text: "Great news! \(time.otherPerson().name) just arrived at the meeting point.")
            }
        } else if old.otherState() != .met && time.otherState() == .met && time.state() != .met {
            presentNotice(photo: time.otherPerson().avatar, text: "\(time.otherPerson().name) says you've found each other. Please confirm to end navigation.")
        }
    }
    
    private func presentNotice(photo: String, text: String) {
        let view: AlertMessageView = try! SwiftMessages.viewFromNib()
        view.configureTheme(backgroundColor: UIColor(red: 244, green: 244, blue: 244), foregroundColor: .clear)
        view.button?.backgroundColor = .clear
        view.content.setup(photo: photo, text: text)
        view.tapHandler = { _ in
            SwiftMessages.hide()
        }
        
        SwiftMessages.show(view: view)
    }
    
    // MARK: - animations
    
    private var messageingExpanded: Bool {
        return messagingTop.constant <= header.frame.height - 12
    }
    
    private var unreadMessages: Int = 0
    
    private func expandMessageView(fully: Bool) {
        
        let padding = fully ? 0 : header.frame.height - 12
        
        guard messagingTop.constant > padding else { return }
        
        initialUI?.removeFromSuperview()
        mapController.bottomPading = 0
        initialOverlayBottom.constant = -68
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { [weak self] in
                self?.header.alpha = fully ? 0 : 1
                if fully {
                    self?.tableViewHeader.setupFull()
                } else {
                    self?.tableViewHeader.setupHalf()
                }
                self?.messagingTop.constant = padding
                self?.tableViewHeader.isHidden = false
                self?.resume.isHidden = true
                self?.view.layoutIfNeeded()
            },
            completion: { [weak self] (_) in
                self?.tableView.scrollToBottom()
            })
        
        header.setupForMessages(highlight: false, count: 0)
        unreadMessages = 0
        
        if let time = time,
            let chat = ChatService.shared.getChats().first(where: { $0.other().id == time.otherPerson().id }) {
            let unreadList = chat.messages?.filter { !$0.isMine() && $0.readAt == nil } ?? []
            guard unreadList.count > 0 else { return }
            DispatchQueue.global(qos: .default).async {
                for message in unreadList {
                    ChatService.shared.setMessageRead(chatId: chat.id, messageId: message.id)
                }
            }
        }
    }
    
    private func collapseMessageView(fully: Bool) {
        
        let padding = fully
            ? view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - tableViewHeader.frame.height - 72
            : header.frame.height - 12
        
        if fully {
            inputBar.reset()
        }
        
        guard messagingTop.constant < padding else { return }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { [weak self] in
                self?.header.alpha = 1
                if fully {
                    self?.tableViewHeader.setupFull()
                } else {
                    self?.tableViewHeader.setupHalf()
                }
                self?.tableViewHeader.isHidden = fully
                self?.resume.isHidden = !fully
                self?.messagingTop.constant = padding
                self?.view.layoutIfNeeded()
            },
            completion: { [weak self] (_) in
                self?.tableView.scrollToBottom()
            })

    }
    
    @objc private func keyboardUp() {
        guard let firstResponder = UIResponder.currentFirstResponder(), firstResponder == inputBar.textView else { return }
        expandMessageView(fully: true)
    }
    
    @objc private func keyboardDown() {
        guard let firstResponder = UIResponder.currentFirstResponder(), firstResponder == inputBar.textView else { return }
        collapseMessageView(fully: false)
    }
    
    // MARK: - messages
    
    private func sendMessage(_ text: String) {
        
        guard let profile = ProfileService.shared.profile,
            let time = time,
            let chat = ChatService.shared.getChats().first(where: { $0.other().id == time.otherPerson().id })
            else { return }
        
        let messageId = "\(profile.id.hashValue)-\(Date().hashValue)"
        let message = Message(id: messageId, createdAt: Date(), sender: profile.shortUser, type: .text, text: text, deliveredAt: nil, readAt: nil)
        
        inputBar.reset()
        tableView.newMessage(message)
        ChatService.shared.sendMessage(chatId: chat.id, message: message)
    }
    
    // MARK: - resume
    
    private func showResume() {
        guard resume.alpha == 0 else { return }
        resume.setTitle("RESUME JOURNEY", for: .normal)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.resume.alpha = 1
        }
        hideWeMet()
    }
    
    private func hideResume() {
        guard resume.alpha > 0 else { return }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.resume.alpha = 0
        }
        showWeMet()
        initialUI?.removeFromSuperview()
        mapController.bottomPading = 0
        initialOverlayBottom.constant = -68
        
        guard !initialOverlay.isHidden else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.overlays.forEach { $0.alpha = 0 }
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.overlays.forEach { $0.isHidden = true }
            })
    }
    
    // MARK: - initial overlay
    
    
    
    // MARK: - add to UI
    
    private func add(view: UIView, bottom: NSLayoutYAxisAnchor? = nil, dockTop: Bool = true) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        if dockTop {
            view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        }
        if let bottom = bottom {
            view.bottomAnchor.constraint(equalTo: bottom).isActive = true
        } else {
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        view.setNeedsLayout()
    }
    
    // MARK: - initial notice
    
    private weak var initialUI: EnRouteNotice? = nil
    
    private func presentInitialUI() {
        
        guard initialUI == nil else { return }
        guard arrivedUI == nil else { return }
        guard cancelUI == nil else { return }
        guard metUI == nil else { return }
        guard let time = time else { return }
        guard time.state() == .none && time.otherState() == .none else { return }
        
        UIResponder.resignAnyFirstResponder()
       
        let view = EnRouteNotice()
        let title = time.isMine() ? "You Accepted \(time.requester.name)'s Request!" : "\(time.signal.creator.name) Accepted Your Request!"
        let text = time.isMine() ? "Meet \(time.requester.name)!" : "Meet \(time.signal.creator.name)!"
        view.setup(title: title, text: text)
        
        mapController.initialNotice = view
        
        add(view: view, bottom: resume.topAnchor, dockTop: false)
        
        initialUI = view
        mapController.bottomPading = 60
        initialOverlayBottom.constant = -128
    }
    
    // mark: - arrived
    
    private weak var arrivedUI: EnRouteArrivedViewController? = nil
    
    private func presentArrivedUI() {

        showWeMet()
        
        guard cancelUI == nil else { return }
        guard metUI == nil else { return }
        guard let time = time else { return }
        guard arrivedUI == nil else { arrivedUI?.setup(for: time); return }
        
        UIResponder.resignAnyFirstResponder()
        
        initialUI?.removeFromSuperview()
        mapController.bottomPading = 0
        initialOverlayBottom.constant = -68
        
        let vc = EnRouteArrivedViewController()
        _ = vc.view
        vc.doneTap = { [weak self] in
            self?.arrivedUI?.view.removeFromSuperview()
            self?.arrivedUI?.removeFromParent()
            self?.arrived()
        }
        vc.backTap = { [weak self] in
            self?.arrivedUI?.view.removeFromSuperview()
            self?.arrivedUI?.removeFromParent()
        }
        vc.setup(for: time, met: false)
        
        add(view: vc.view)
        addChild(vc)
        
        arrivedUI = vc
    }
    
    private func arrived() {
        guard let time = time else { return }
        TimesService.shared.arrivedTime(experienceId: time.post.experience.id, timeId: time.id)
        hideWeMet()
    }

    // MARK: - met
    
    private weak var metUI: EnRouteArrivedViewController? = nil
    
    private func presentMetUI() {

        showWeMet()
        
        guard cancelledUI == nil else { return }
        guard cancelUI == nil else { return }
        guard let time = time else { return }
        guard metUI == nil else { metUI?.setup(for: time); return }
        
        UIResponder.resignAnyFirstResponder()
        
        initialUI?.removeFromSuperview()
        mapController.bottomPading = 0
        initialOverlayBottom.constant = -68
        
        arrivedUI?.view.removeFromSuperview()
        arrivedUI?.removeFromParent()
        
        let vc = EnRouteArrivedViewController()
        _ = vc.view
        vc.doneTap = { [weak self] in
            self?.metUI?.view.removeFromSuperview()
            self?.metUI?.removeFromParent()
            self?.endTime()
        }
        vc.backTap = { [weak self] in
            self?.metUI?.view.removeFromSuperview()
            self?.metUI?.removeFromParent()
        }
        vc.setup(for: time)
        
        add(view: vc.view)
        addChild(vc)
        
        metUI = vc
    }
    
    private func hideWeMet() {
        meetupBar.isHidden = true
        mapController.bottomPading = 0
        initialOverlayBottom.constant = -68
    }
    
    private func showWeMet() {
        guard resume.alpha == 0 else { return }
        guard let time = time, time.state() == .queryArrived || time.state() == .queryMet || time.state() == .met else { return }
       
        meetupBar.isHidden = false
        meetupBar.tap = nil
    
        if time.state() == .queryArrived {
            meetupBar.type = .arrive
            meetupBar.tap = { [weak self] in
                self?.presentArrivedUI()
            }
            meetupBar.setup(text: "Did you arrive at the meeting point?")
        } else if time.state() == .met {
            meetupBar.type = .met
            meetupBar.setup(text: "Waiting for \(time.otherPerson().name) to confirm...")
        } else {
            meetupBar.type = .met
            meetupBar.tap = { [weak self] in
                self?.presentMetUI()
            }
            meetupBar.setup(text: "Did you find each other?")
        }
    }
    
    private func endTime() {
        guard let time = time else { return }
        TimesService.shared.finishTime(timeId: time.id, creator: time.isMine())
        
        if time.otherState() == .met {
            guard let presenter = presentingViewController as? MoreTabBarNestedNavigationController else { return }
            presenter.dismiss(animated: true, completion: nil)
        } else {
            showWeMet()
        }
    }
    
    // MARK: - cancel
    
    private weak var cancelUI: EnRouteSafetyViewController? = nil
    
    func presentCancelUI() {
        
        guard cancelledUI == nil else { return }
        guard let time = time else { return }
        
        UIResponder.resignAnyFirstResponder()
        
        initialUI?.removeFromSuperview()
        mapController.bottomPading = 0
        initialOverlayBottom.constant = -68
        
        arrivedUI?.view.removeFromSuperview()
        arrivedUI?.removeFromParent()
        
        metUI?.view.removeFromSuperview()
        metUI?.removeFromParent()
        
        let vc = EnRouteSafetyViewController()
        _ = vc.view
        vc.close = { [weak self] (canceled) in
            self?.cancelUI?.view.removeFromSuperview()
            self?.cancelUI?.removeFromParent()
            
            if canceled {
                guard let presenter = self?.presentingViewController else { return }
                presenter.dismiss(animated: true, completion: nil)
            }
        }
        vc.setup(for: time)
        
        add(view: vc.view)
        addChild(vc)
        
        cancelUI = vc
    }
    
    // MARK: - cancelled
    
    private weak var cancelledUI: EnRouteCancelledViewController? = nil
    
    func presentCancelledUI() {
        
        guard let time = time else { return }
        
        UIResponder.resignAnyFirstResponder()
        
        initialUI?.removeFromSuperview()
        mapController.bottomPading = 0
        initialOverlayBottom.constant = -68
        
        arrivedUI?.view.removeFromSuperview()
        arrivedUI?.removeFromParent()
        
        metUI?.view.removeFromSuperview()
        metUI?.removeFromParent()
        
        cancelledUI?.view.removeFromSuperview()
        cancelledUI?.removeFromParent()
        
        let vc = EnRouteCancelledViewController()
        _ = vc.view
        vc.doneTap = { [weak self] in
            self?.cancelledUI?.view.removeFromSuperview()
            self?.cancelledUI?.removeFromParent()
            TimesService.shared.closeTime(timeId: time.id, creator: time.isMine())
            
            guard let presenter = self?.presentingViewController else { return }
            presenter.dismiss(animated: true, completion: nil)
        }
        vc.setup(for: time)
        
        add(view: vc.view)
        addChild(vc)
        
        cancelledUI = vc
    }
    
    // MARK: - profile
    
    private func presentProfile() {
        guard let time = time else { return }
        presentUser(time.otherPerson().id)
    }
    
    // MARK: - signal
    
    private func presentSignal() {
        guard let time = time else { return }
        presentSignal(time.signal.id)
    }
    
    
    // MARK: - typing
    
    private func trackTyping() {
        // me typing
        inputBar.isTypingChanged = { [weak self] in
            guard let time = self?.time else { return }
            guard let chat = ChatService.shared.getChats().first(where: { $0.other().id == time.otherPerson().id }) else { return }
            guard let isTyping = self?.inputBar.isTyping else { return }
            
            ChatService.shared.setTyping(typing: isTyping, in: chat.id)
        }
    }
    
    private func stopTrackingTyping() {
        inputBar.isTypingChanged = nil
    }
}
