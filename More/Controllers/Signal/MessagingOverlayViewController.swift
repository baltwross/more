//
//  MessagingOverlayViewController.swift
//  More
//
//  Created by Luko Gjenero on 24/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class RequestMessagingOverlayViewController: UIViewController {

    @IBOutlet private weak var requestBar: SignalRequestBar!
    @IBOutlet private weak var topBar: SignalRequestTopBar!
    @IBOutlet private weak var messagingView: MessagingView!
    
    private var presenting: Bool = false
    private var model: SignalViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestBar.isHidden = false
        topBar.isHidden = true
        messagingView.isHidden = true
        
        requestBar.requestTap = { [weak self] in
            self?.requestTimeIfNeeded()
        }
        
        topBar.downTap = { [weak self] in
            self?.hideMessagingView()
        }
        
        for constraint in view.constraints {
            if constraint.firstAnchor == messagingView.bottomAnchor ||
                constraint.secondAnchor == messagingView.bottomAnchor {
                bottomContraint = constraint
                break
            }
        }
        trackKeyboardAndPushUp()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: SignalTrackingService.Notifications.SignalExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: SignalTrackingService.Notifications.SignalResponse, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: SignalTrackingService.Notifications.SignalMessage, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        topBar.safeAreaHeight = view.safeAreaInsets.top
    }


    func presentMessagingView() {
        
        guard !presenting else { return }
        presenting = true
        
        let start = view.frame.height - requestBar.frame.height
        
        topBar.layer.transform = CATransform3DMakeTranslation(0, start, 0)
        messagingView.layer.transform = CATransform3DMakeTranslation(0, start, 0)
        
        topBar.isHidden = false
        messagingView.isHidden = false
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.topBar.layer.transform = CATransform3DIdentity
                self.messagingView.layer.transform = CATransform3DIdentity
            },
            completion: { (_) in
                self.messagingView.showKeyboard()
            })
    }
    
    func hideMessagingView() {
        
        guard presenting else { return }
        presenting = false
    
        let end = view.frame.height - requestBar.frame.height
    
        topBar.layer.transform = CATransform3DIdentity
        messagingView.layer.transform = CATransform3DIdentity
        
        topBar.isHidden = false
        messagingView.isHidden = false
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.topBar.layer.transform = CATransform3DMakeTranslation(0, end, 0)
                self.messagingView.layer.transform = CATransform3DMakeTranslation(0, end, 0)
        },
            completion: { (_) in
                self.topBar.isHidden = true
                self.messagingView.isHidden = true
                self.messagingView.hideKeyboard()
        })
    }
    
    func setup(for model: SignalViewModel) {
        
        self.model = model
        topBar.setup(for: model)
        messagingView.setup(for: model.messages)
        requestBar.setup(for: model)
    }
    
    // MARK: - interaction

    @objc private func updateData(_ notice: Notification) {
        if let signal = notice.userInfo?["signal"] as? Signal, signal.id == model?.id {
            setup(for: SignalViewModel(signal: signal))
        }
    }
    
    private func requestTimeIfNeeded() {
        guard let model = model else { return }
        guard let profile = ProfileService.shared.profile else { return }
        
        if model.requested == true {
            presentMessagingView()
        } else {
            showLoading()
            SignalingService.shared.requestTime(for: model.id) { [weak self] (requestId, erroMsg) in
                
                self?.hideLoading()
                
                if let requestId = requestId {
                    let request = Request(
                        id: requestId,
                        createdAt: Date(),
                        expiresAt: Date(timeIntervalSinceNow: 180),
                        sender: profile.user,
                        accepted: nil)
                    
                    // TODO ??
                    
                    self?.presentMessagingView()
                } else {
                    self?.showSimpleAlert(title: "Error", message: erroMsg ?? "Unknown", complete: nil)
                }
            }
        }
    }
}

class MessagingOverlayViewControllerView : UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit == self {
            return nil
        }
        return hit
    }
    
}
