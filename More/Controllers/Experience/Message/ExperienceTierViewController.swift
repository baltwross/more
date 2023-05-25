//
//  ExperienceTierViewController.swift
//  More
//
//  Created by Luko Gjenero on 02/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ExperienceTierViewController: ExperienceRequestViewController {

    @IBOutlet private weak var spotsBottom: NSLayoutConstraint!
    @IBOutlet private weak var spotsContainer: UIView!
    @IBOutlet private weak var spotsLabel: UILabel!
    @IBOutlet private weak var tierInfo: ExperienceTierInfo!
    @IBOutlet private weak var tierBarContainer: UIView!
    @IBOutlet private weak var tierBar: ExperienceTierBar!
    
    var profile: (()->())?
    var chat: (()->())?
    
    private var experience: Experience?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tierBarContainer.enableShadow(color: .black)
        tierInfo.enableShadow(color: .black)
        
        spotsLabel.layer.cornerRadius = 15
        spotsLabel.layer.masksToBounds = true
        spotsContainer.enableStrongShadow(color: .black, opacity: 0.3)

        tierBar.infoTap = { [weak self] in
            guard let experience = self?.experience else { return }
            guard let post = experience.activePost() else { return }
            
            if let myRequest = post.myRequest(), myRequest.accepted == true {
                self?.expandInfo()
            } else if let count = post.requests?.filter({ $0.accepted == true }).count,
                count >= Config.Experience.virtualSpots - 1 {
                self?.askToJoinWaitingList()
            } else {
                self?.expandInfo()
            }
        }
        tierBar.joinTap = { [weak self] in
            guard let experience = self?.experience else { return }
            guard let post = experience.activePost() else { return }
            
            if let myRequest = post.myRequest(), myRequest.accepted == true {
                self?.chat?()
            } else {
                self?.joinExperience()
            }
        }
        tierBar.profileTap = { [weak self] in
            self?.profile?()
        }
        
        collapseInfo(animated: false)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragContent(sender:)))
        tierInfo.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    override func setup(for experience: Experience) {
        self.experience = experience
        
        guard let post = experience.activePost() else { return }
        
        guard !post.creator.isMe() else {
            tierInfo.isHidden = true
            tierBarContainer.isHidden = true
            let count = post.requests?.filter({ $0.accepted == true }).count ?? 0
            spotsContainer.isHidden = false
            spotsLabel.text = "\(Config.Experience.virtualSpots - 1 - count) spots left!"
            spotsBottom.constant = -70
            return
        }
        
        tierInfo.isHidden = false
        tierBarContainer.isHidden = false
        spotsBottom.constant = 20
        
        tierBar.setup(for: post)
        if let count = post.requests?.filter({ $0.accepted == true }).count {
            if let myRequest = post.myRequest(), myRequest.accepted == true {
                spotsContainer.isHidden = true
                tierBar.setupForPurchased()
            } else if count >= Config.Experience.virtualSpots - 1 {
                spotsContainer.isHidden = true
                tierBar.setupForSoldOut()
            } else {
                spotsContainer.isHidden = false
                spotsLabel.text = "\(Config.Experience.virtualSpots - 1 - count) spots left!"
            }
        } else {
            spotsContainer.isHidden = false
            spotsLabel.text = "\(Config.Experience.virtualSpots - 1) spots left!"
        }
    }
    
    // MARK: - join
    
    private func joinExperience() {
        guard let experience = experience else { return }
        guard let post = experience.activePost() else { return }
        guard let tier = experience.tier else { return }
        guard let user = ProfileService.shared.profile?.user else { return }
        
        showLoading()
        
        // 1. check spots
        // 2. reserve spot
        // 3. purchase
        // 4. claim reserved spot

        
        ExperienceService.shared.reserveVirtualExperienceRequest(for: experience, post: post, complete: { [weak self] (success, errorMsg) in
            
            if !success {
                self?.hideLoading()
                self?.soldOut()
                return
            }
            
            InAppPurchaseService.shared.purchase(tier: tier.id) { (success, transaction, errorMsg) in
                
                if !success {
                    self?.hideLoading()
                    self?.errorAlert(text: errorMsg ?? "Unknown error")
                    ExperienceService.shared.cancelVirtualExperienceRequestReservation(for: experience, post: post, complete: nil)
                    return
                }
                
                let request = ExperienceRequest(
                    id: "",
                    createdAt: Date(),
                    creator: user.short(),
                    post: post.short(),
                    message: nil)
                
                ExperienceService.shared.createExperienceRequest(for: experience, post: post, request: request) { (requestId, errorMsg) in
                    self?.hideLoading()
                    
                    if requestId == nil {
                        self?.errorAlert(text: errorMsg ?? "Unknown error")
                        ExperienceService.shared.cancelVirtualExperienceRequestReservation(for: experience, post: post, complete: nil)
                        
                        // TODO: - what to do with the monies ???
                    } else {
                        if let transaction = transaction {
                            IAPHelper.shared.finishTransaction(transaction)
                        }
                        self?.done?()
                    }
                }
            }
        })
    }
    
    // MARK: - sold Out
    
    private weak var soldOutView: UIView?
    
    private func soldOut() {
        
        spotsContainer.isHidden = true
        tierBar.setupForSoldOut()
        
        let popupView = UIView()
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.backgroundColor = UIColor.charcoalGrey.withAlphaComponent(0.4)
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeSoldOut))
        popupView.addGestureRecognizer(tap)
        
        let bubble = ExperienceTierFullPopup()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        
        popupView.addSubview(bubble)
        bubble.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 150).isActive = true
        bubble.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 25).isActive = true
        bubble.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -25).isActive = true
        
        view.addSubview(popupView)
        popupView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        bubble.joinTap = { [weak self] in
            self?.closeSoldOut(join: true)
        }
        if let post = experience?.activePost() {
            bubble.setup(for: post)
        }
        
        popupView.alpha = 0
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak popupView] in
                popupView?.alpha = 1
            },
            completion: { _ in
                // nop
            })
        
        soldOutView = popupView
    }
    
    @objc private func closeSoldOut(join: Bool = false) {
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.soldOutView?.alpha = 0
            },
            completion: { [weak self] _ in
                self?.soldOutView?.removeFromSuperview()
                if join {
                    self?.notifyOnWaitingList()
                }
            })
    }
    
    private func askToJoinWaitingList() {
        let alert = UIAlertController(title: "Join Waitlist?", message: "We'll notify you if a spot opens up, or when this user goes online again.", preferredStyle: .alert)
        
        let join = UIAlertAction(title: "Save draft", style: .default, handler: { [weak self] _ in
            self?.notifyOnWaitingList()
        })
        
        alert.addAction(join)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func notifyOnWaitingList() {
        let alert = UIAlertController(title: "You Got It", message: "You’ll get notified if a spot opens up.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - expand collapse info
    
    private func expandInfo(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.expandInfoLayout()
            }
        } else {
            expandInfoLayout()
        }
    }
    
    private func expandInfoLayout() {
        tierInfo.layer.transform = CATransform3DIdentity
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    private func collapseInfo(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collapseInfoLayout()
            }
        } else {
            collapseInfoLayout()
        }
    }
    
    private func collapseInfoLayout() {
        tierInfo.layer.transform = CATransform3DMakeTranslation(0, (view.frame.height - 60), 0)
        view.backgroundColor = .clear
    }
    
    override func fullyCollapse(animated: Bool = true) {
        collapseInfo(animated: animated)
    }
    
    override var isCollapsed: Bool {
        return tierInfo.layer.transform.m42 > 0
    }
    
    // MARK: - drag
    
    private var dragStart: CGPoint = .zero
    
    @objc private func dragContent(sender: UIPanGestureRecognizer) {
        
        guard view.layer.animationKeys() == nil else { return }
        
        let point = sender.location(in: view)
        let offset = dragStart.y - point.y
        switch sender.state {
        case .began:
            dragStart = point
        case .changed:
            move(to: -offset)
        case .cancelled, .ended, .failed:
            settle(to: -offset)
        default: ()
        }
    }
    
    private func move(to offset: CGFloat) {
        let clampedOffset = max(0, min(offset, tierInfo.frame.width - 15))
        tierInfo.layer.transform = CATransform3DMakeTranslation(0, clampedOffset, 0)
    }
    
    private func settle(to offset: CGFloat) {
        let maxDrag = tierInfo.frame.width - 15
        let clampedOffset = max(0, min(offset, maxDrag))
        if clampedOffset > maxDrag / 2 {
            collapseInfo()
        } else {
            expandInfo()
        }
    }
}
