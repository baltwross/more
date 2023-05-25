//
//  EnRouteV2ViewController.swift
//  More
//
//  Created by Luko Gjenero on 17/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Mapbox
import Lottie

// animation keyframes
private let shareAnimPhase1: AnimationProgressTime = 242.0 / 635.0
private let shareAnimPhase2: AnimationProgressTime = 362.0 / 635.0
private let shareAnimPhase3: AnimationProgressTime = 560.0 / 635.0

class EnRouteV2ViewController: MoreBaseViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapBox: MGLMapView!
    
    // buttons
    @IBOutlet weak var recenterBubble: UIView!
    @IBOutlet weak var recenterLabel: UILabel!
    @IBOutlet var recenterWidth: NSLayoutConstraint!
    @IBOutlet weak var recenterButton: UIButton!
    @IBOutlet weak var shareBubble: UIView!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet var shareWidth: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareAnimation: UIView!
    @IBOutlet weak var cancelBubble: UIView!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet var cancelWidth: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    
    // chat
    private var chatContainer: UIView!
    private var chatBit: UIView!
    private weak var pairHeader: ChatViewLeftHeader?
    private weak var groupHeader: GroupChatViewLeftHeader?
    private var chatController: ChatViewController!
    private var chatHeight: NSLayoutConstraint!
    private var chatBottom: NSLayoutConstraint!
    // private var chatTop: NSLayoutConstraint!
    private var notPresenting = true
    
    // state
    @IBOutlet private weak var stateContainer: UIView!
    @IBOutlet private weak var stateContainerHeight: NSLayoutConstraint!
    
    private var time: ExperienceTime?
    
    private var mapController: EnRouteV2ViewMapController!
    private var stateController: EnRouteV2ViewStateController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .fullScreen
        
        dropShadow(for: recenterBubble)
        recenterButton.layer.cornerRadius = 22.5
        dropShadow(for: shareBubble)
        shareButton.layer.cornerRadius = 22.5
        dropShadow(for: cancelBubble)
        cancelButton.layer.cornerRadius = 32.5
        
        recenterLabel.enableShadow(color: .black)
        recenterButton.enableShadow(color: .black)
        shareLabel.enableShadow(color: .black)
        shareButton.enableShadow(color: .black)
        cancelLabel.enableShadow(color: .black)
        cancelButton.enableShadow(color: .black)
        
        recenterWidth.isActive = false
        shareWidth.isActive = false
        cancelWidth.isActive = false
        
        setupLocationShare()
        
        mapController = EnRouteV2ViewMapController(mapBox: mapBox)
        stateController = EnRouteV2ViewStateController(container: stateContainer, height: stateContainerHeight, root: self)
        
        setupChatView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stateController.appeared()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            UIView.animate(withDuration: 0.3) {
                guard let sself = self else { return }
                sself.recenterWidth.isActive = true
                sself.shareWidth.isActive = true
                sself.cancelWidth.isActive = true
                sself.view.layoutIfNeeded()
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stateController.disappeared()
    }
    
    private func dropShadow(for view: UIView) {
        view.layer.cornerRadius = 11
        view.enableShadow(color: .black)
    }
    
    private func setupChatHeader(for chat: Chat) {
        if chat.memberIds.count > 2 {
            pairHeader?.removeFromSuperview()
            if let existing = groupHeader {
                existing.setup(for: chat)
            } else {
                let header = GroupChatViewLeftHeader()
                header.translatesAutoresizingMaskIntoConstraints = false
                header.hideBack()
                header.groupTap = nil

                chatContainer.addSubview(header)
                header.topAnchor.constraint(equalTo: chatContainer.topAnchor, constant: 20).isActive = true
                header.leadingAnchor.constraint(equalTo: chatContainer.leadingAnchor).isActive = true
                header.trailingAnchor.constraint(equalTo: chatContainer.trailingAnchor).isActive = true
                header.heightAnchor.constraint(equalToConstant: 50).isActive = true
                
                header.setup(for: chat)
                groupHeader = header
                
                //  expand chat
                let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
                pan.delegate = self
                pan.cancelsTouchesInView = true
                header.addGestureRecognizer(pan)
            }
        } else {
            groupHeader?.removeFromSuperview()
            if let existing = pairHeader {
                existing.setup(for: chat.other())
            } else {
                let header = ChatViewLeftHeader()
                header.translatesAutoresizingMaskIntoConstraints = false
                header.hideBack()
                header.profileTap = { [weak self] in
                    self?.presentUser(chat.other().id)
                }
                
                chatContainer.addSubview(header)
                header.topAnchor.constraint(equalTo: chatContainer.topAnchor, constant: 20).isActive = true
                header.leadingAnchor.constraint(equalTo: chatContainer.leadingAnchor).isActive = true
                header.trailingAnchor.constraint(equalTo: chatContainer.trailingAnchor).isActive = true
                header.heightAnchor.constraint(equalToConstant: 50).isActive = true
                
                header.setup(for: chat.other())
                pairHeader = header
                
                //  expand chat
                let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
                pan.delegate = self
                pan.cancelsTouchesInView = true
                header.addGestureRecognizer(pan)
            }
        }
    }
    
    // MARK: - setup
    
    func setup(for time: ExperienceTime) {
        self.time = time
        
        mapController.setupMap(for: time)
        stateController.setup(for: time)
        
        guard let chat = ChatService.shared.getChat(for: time.chat.memberIds) else { return }
        
        setupChatHeader(for: chat)
        chatController.setup(chat: chat)
        
        checkSharingLocation()
    }
    
    // MARK: - map buttons
    
    @IBAction private func recenterTouch(_ sender: Any) {
        mapController.reset()
    }
    
    @IBAction private func shareTouch(_ sender: Any) {
        if shareTimer == nil {
            shareLocation()
        } else {
            stopSharingLocation()
        }
    }
    
    @IBAction private func cancelTouch(_ sender: Any) {
        guard let time = time else { return }
        let vc = EnRouteCancelViewController()
        vc.setup(for: time)
        vc.back = { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.notPresenting = true
            })
        }
        vc.cancel = { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.notPresenting = true
                self?.dismiss(animated: true, completion: nil)
            })
        }
        notPresenting = false
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - chat
    
    private var chatExpandedHeight: CGFloat {
        return view.bounds.height - 300
    }
    
    @objc private func keyboardUp(_ notification: Notification) {
        guard notPresenting else { return }
        if chatHeight.constant < chatExpandedHeight {
            animateLayout(height: chatExpandedHeight, info: notification.userInfo)
        }
    }
    
    @objc private func keyboardDown(_ notification: Notification) {
        guard notPresenting else { return }
        if chatHeight.constant > 0 {
            animateLayout(height: 0, info: notification.userInfo)
        }
    }
    
    private func animateLayout(height: CGFloat, info: [AnyHashable: Any]?) {
        
        guard chatHeight.constant != height else { return }
        
        var curve: UIView.AnimationOptions = .curveEaseInOut
        var duration: TimeInterval = 0.3

        if let userInfo = info,
            let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {

            curve = UIView.AnimationOptions(rawValue: animationCurve.uintValue)
            duration = animationDuration.doubleValue
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: curve,
            animations: { [weak self] in
                self?.chatHeight.constant = height
                self?.view.layoutIfNeeded()
            },
            completion: nil)
    }
    
    private func setupChatView() {
        
        chatContainer = UIView()
        chatContainer.translatesAutoresizingMaskIntoConstraints = false
        chatContainer.backgroundColor = .whiteTwo
        chatContainer.layer.cornerRadius = 12
        chatContainer.enableShadow(color: .black)
        
        // top bit
        let chatBit = UIView()
        chatBit.translatesAutoresizingMaskIntoConstraints = false
        chatBit.backgroundColor = .lightPeriwinkle
        
        chatContainer.addSubview(chatBit)
        chatBit.topAnchor.constraint(equalTo: chatContainer.topAnchor, constant: 10).isActive = true
        chatBit.centerXAnchor.constraint(equalTo: chatContainer.centerXAnchor).isActive = true
        chatBit.widthAnchor.constraint(equalToConstant: 50).isActive = true
        chatBit.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        // chat
        chatController = ChatViewController()
        chatController.view.translatesAutoresizingMaskIntoConstraints = false
        
        chatContainer.addSubview(chatController.view)
        chatController.view.topAnchor.constraint(equalTo: chatContainer.topAnchor, constant: 75).isActive = true
        chatController.view.leadingAnchor.constraint(equalTo: chatContainer.leadingAnchor).isActive = true
        chatController.view.trailingAnchor.constraint(equalTo: chatContainer.trailingAnchor).isActive = true
        chatController.view.bottomAnchor.constraint(equalTo: chatContainer.bottomAnchor).isActive = true
        chatHeight = chatController.getChatViewHeight()
        chatHeight.priority = .defaultLow
        chatHeight.isActive = true
        
        view.addSubview(chatContainer)
        
        chatContainer.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        chatContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chatContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chatBottom = chatContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        chatBottom.isActive = true
    }
    
    // MARK: - swipe to expand
    
    private var startHeight: CGFloat = 0
    private var skipCancel: Bool = false
    
    @objc private func pan(sender: UIPanGestureRecognizer) {
        
        let offset = sender.translation(in: view).y
        switch sender.state {
        case .began:
            startHeight = chatHeight.constant
        case .changed:
            chatHeight.constant = startHeight - offset
            if chatHeight.constant <= 0 {
                skipCancel = true
                sender.isEnabled = false
                sender.isEnabled = true
                UIResponder.currentFirstResponder()?.resignFirstResponder()
            }
        case .cancelled:
            if !skipCancel {
                chatHeight.constant = startHeight - offset
                settleChat()
            }
            skipCancel = false
        case .ended, .failed:
            chatHeight.constant = startHeight - offset
            settleChat()
        default: ()
        }
    }
    
    private func settleChat() {
        if chatHeight.constant > chatExpandedHeight * 0.5 {
            animateLayout(height: chatExpandedHeight, info: nil)
        } else {
            animateLayout(height: 0, info: nil)
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - share
    
    private var shareTimer: Timer?
    
    private func shareLocation(startTimer: Bool = true) {
        shareLabel.text = "Stop sharing Location"
        
        // animate the ghost
        shareAnimation.lottieView?.play(toProgress: shareAnimPhase2, loopMode: .playOnce, completion: { [weak self] (finished) in
            if finished {
                self?.shareAnimation.lottieView?.play(fromProgress: shareAnimPhase2, toProgress: shareAnimPhase3, loopMode: .loop, completion: nil)
            }
        })
        
        if startTimer {
            let fiveMins = Date(timeIntervalSinceNow: 300)
            TimesService.shared.shareActiveTimeLocation(until: fiveMins)
            shareLocationTimer(fiveMins)
        }
    }
    
    private func shareLocationTimer(_ date: Date) {
        shareTimer?.invalidate()
        shareTimer = Timer.scheduledTimer(withTimeInterval: date.timeIntervalSinceNow, repeats: false) { [weak self] (_) in
            self?.shareTimer = nil
            self?.stopSharingLocation()
        }
    }
    
    private func stopSharingLocation() {
        shareTimer?.invalidate()
        shareTimer = nil
        
        // animate the ghost
        shareAnimation.lottieView?.play(toProgress: shareAnimPhase1, loopMode: .playOnce, completion: nil)
        
        shareLabel.text = "Share Location"
        let past = Date(timeIntervalSinceNow: -300)
        TimesService.shared.shareActiveTimeLocation(until: past)
    }
    
    private func checkSharingLocation() {
        let until = TimesService.shared.currentActiveTimeLocationTracking
        let now = Date()
        if until > now {
            shareLocation(startTimer: false)
            shareLocationTimer(until)
        }
    }
    
    private func setupLocationShare() {
        shareAnimation.addGhostAnimation()
        shareAnimation.lottieView?.animationSpeed = 2
        shareAnimation.lottieView?.currentProgress = shareAnimPhase1
    }

}
