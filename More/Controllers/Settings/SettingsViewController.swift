//
//  SettingsViewController.swift
//  More
//
//  Created by Luko Gjenero on 13/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class SettingsViewController: UIViewController {

    @IBOutlet private weak var content: UIView!
    @IBOutlet private weak var version: UILabel!
    
    // debug options
    
    @IBOutlet private weak var firebaseTokenLabel: UILabel!
    @IBOutlet private weak var firebaseToken: UIButton!
    @IBOutlet private weak var firebaseIdLabel: UILabel!
    @IBOutlet private weak var firebaseId: UIButton!
    
    var closeTap: (()->())?
    var inviteTap: (()->())?
    var supportTap: (()->())?
    var termsTap: (()->())?
    var privacyTap: (()->())?
    var logoutTap: (()->())?
    var deleteTap: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragContent(sender:)))
        view.addGestureRecognizer(pan)
        
        let major = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let minor = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        
        version.text = "v\(major) (\(minor))"
        
        prepareForEnter()
        
        setupDebug()
    }
    
    private var isFirst = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        enter()
    }

    @IBAction private func closeTouch(_ sender: Any) {
        exit { [weak self] in
            self?.closeTap?()
        }
    }
    
    @IBAction private func inviteTouch(_ sender: Any) {
        inviteTap?()
    }
    
    @IBAction private func supportTouch(_ sender: Any) {
        supportTap?()
    }
    
    @IBAction private func termsTouch(_ sender: Any) {
        termsTap?()
    }
    
    @IBAction private func privacyTouch(_ sender: Any) {
        privacyTap?()
    }
    
    @IBAction private func logoutTouch(_ sender: Any) {
        logoutTap?()
    }
    
    @IBAction private func deleteTouch(_ sender: Any) {
        deleteTap?()
    }
    
    // MARK: - drag
    
    private var dragStart: CGPoint = .zero
    
    @objc private func dragContent(sender: UIPanGestureRecognizer) {
        
        guard content.layer.animationKeys() == nil else { return }
        
        let point = sender.location(in: view)
        let offset = dragStart.x - point.x
        switch sender.state {
        case .began:
            dragStart = point
        case .changed:
            moveTop(to: offset)
        case .cancelled, .ended, .failed:
            settleTop(to: offset)
        default: ()
        }
    }
    
    private func moveTop(to offset: CGFloat) {
        let clampedOffset = max(offset, 0)
        content.layer.transform = CATransform3DMakeTranslation(-clampedOffset, 0, 0)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3 * (1 - clampedOffset / content.frame.width))
    }
    
    private func settleTop(to offset: CGFloat) {
        if offset > content.frame.width * 0.25 {
            exit { [weak self] in
                self?.closeTap?()
            }
        } else {
            enter()
        }
    }
    
    // MARK: - animations
    
    private func prepareForEnter() {
        view.backgroundColor = .clear
        content.layer.transform = CATransform3DMakeTranslation(-UIScreen.main.bounds.width, 0, 0)
    }
    
    private func enter() {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.content.layer.transform = CATransform3DIdentity
        }
    }
    
    private func exit(_ complete: @escaping ()->()) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.prepareForEnter()
            },
            completion: { _ in
                complete()
            })
    }
    
    // MARK: - debug
    
    private func setupDebug() {
        guard let me = ProfileService.shared.profile, me.isAdmin == true else {
            hideDebug(true)
            return
        }
        hideDebug(false)
        Messaging.messaging().token { [weak self] token, error in
            if let token = token {
                self?.firebaseToken.setTitle(token, for: .normal)
                self?.firebaseId.setTitle("N/A", for: .normal) // Firebase Messaging doesn't provide an Instance ID like Instance ID did
            } else {
                self?.firebaseToken.setTitle("Error", for: .normal)
                self?.firebaseId.setTitle("Error", for: .normal)
            }
        }

        
        /*
        InstanceID.instanceID().instanceID { [weak self] result, error in
            if let result = result {
                self?.firebaseToken.setTitle(result.token, for: .normal)
                self?.firebaseId.setTitle(result.instanceID, for: .normal)
            } else {
                self?.firebaseToken.setTitle("Error", for: .normal)
                self?.firebaseId.setTitle("Error", for: .normal)
            }
        } */
    }
    
    private func hideDebug(_ hide: Bool) {
        firebaseTokenLabel.isHidden = hide
        firebaseToken.isHidden = hide
        firebaseIdLabel.isHidden = hide
        firebaseId.isHidden = hide
    }
    
    @IBAction private func firebaseTokenTouch(_ sender: Any) {
        UIPasteboard.general.string = firebaseToken.title(for: .normal)
    }
    
    
    @IBAction private func firebaseIdTouch(_ sender: Any) {
        UIPasteboard.general.string = firebaseId.title(for: .normal)
    }
    
}
