//
//  ExperienceDetailsNavigationController.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ExperienceDetailsNavigationController : UIViewController {

    private var bottomPadding: CGFloat = 0
    
    var back: (()->())?
    var share: (()->())?
    var report: (()->())?
    var edit: (()->())?
    var requested: (()->())?
    var claimed: (()->())?
    var deleted: (()->())?
    var chat: (()->())?
    var activated: ((_ post: ExperiencePost)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNestedNavigation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setup(for experience: Experience) {
        let vc = ExperienceDetailsViewController()
        vc.backTap = { [weak self] in
            self?.back?()
        }
        vc.shareTap = { [weak self] in
            self?.share?()
        }
        vc.moreTap = { [weak self] in
            if experience.creator.isMe() {
                self?.edit?()
            } else {
                self?.report?()
            }
        }
        vc.scrolling = { [weak self] in
            self?.overlay?.fullyCollapse()
        }
        _ = vc.view
    
        let updatedExperience = ExperienceTrackingService.shared.updatedExperienceData(for: experience.id) ?? experience
        
        vc.setup(for: updatedExperience)
        navigation.setViewControllers([vc], animated: false)
        navigation.delegate = self
        
        vc.bottomPadding = 73
        bottomPadding = 73
        
        if let post = updatedExperience.activePost() {
            if experience.isVirtual == true && experience.tier != nil {
                setupTierOverlay(for: experience)
            } else {
                if post.chat != nil {
                    setupGroupRequestOverlay(for: updatedExperience)
                } else {
                    setupSingleRequestOverlay(for: updatedExperience)
                }
            }
        } else {
            setupClaimRequestOverlay(for: updatedExperience)
        }
    }
    
    func setupForOwn(_ experience: Experience) {
        let vc = ExperienceDetailsViewController()
        vc.backTap = { [weak self] in
            self?.back?()
        }
        vc.shareTap = { [weak self] in
            self?.share?()
        }
        vc.moreTap = { [weak self] in
            self?.edit?()
        }
        vc.scrolling = { [weak self] in
            self?.overlay?.fullyCollapse()
        }
        _ = vc.view
        
        vc.setup(for: experience)
        navigation.setViewControllers([vc], animated: false)
        navigation.delegate = self
        
        vc.bottomPadding = 73
        bottomPadding = 73
        
        setupDeleteOverlay(for: experience)
    }
    
    func setupForPast(_ experience: Experience) {
        let vc = ExperienceDetailsViewController()
        vc.backTap = { [weak self] in
            self?.back?()
        }
        vc.shareTap = { [weak self] in
            self?.share?()
        }
        vc.moreTap = { [weak self] in
            self?.report?()
        }
        _ = vc.view
        
        vc.setup(for: experience)
        navigation.setViewControllers([vc], animated: false)
        navigation.delegate = self
        
        vc.bottomPadding = 73
        bottomPadding = 73
        
        removeOverlay()
    }
    
    // MARK: - helpers
    
    private func addViewController(_ viewController: UIViewController) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.willMove(toParent: self)
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        viewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func removeOverlay() {
        overlay?.willMove(toParent: nil)
        overlay?.removeFromParent()
        overlay?.view.removeFromSuperview()
        overlay?.didMove(toParent: nil)
        overlay = nil
    }
    
    // MARK: - navigation controller
    
    private let navigation = SignalDetailsNavigation()
    
    private func setupNestedNavigation() {
        addViewController(navigation)
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.enableSwipeToPop()
    }
    
    // MARK: -  overlay
    
    private var overlay: ExperienceRequestViewController?
    
    private func setupSingleRequestOverlay(for experience: Experience) {
        
        if overlay is ExperienceRequestSingleMessageViewController {
            return
        }
        removeOverlay()
        
        let singleOverlay = ExperienceRequestSingleMessageViewController()
        addViewController(singleOverlay)
        // view.setNeedsLayout()
        
        singleOverlay.setup(for: experience)
        singleOverlay.done = { [weak self] in
            self?.requested?()
        }
        singleOverlay.deleted = { [weak self] in
            self?.deleted?()
        }
        singleOverlay.profile = { [weak self] in
            let now = Date()
            if let post = experience.posts?.first(where: { $0.isActive(now) }) {
                self?.presentUser(post.creator.id)
            }
        }
        singleOverlay.error = { [weak self] errorMsg in
            let alert = UIAlertController(title: "Error happened", message: errorMsg ?? "Unable to perform the action at the moment, please try again.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self?.back?()
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        
        self.overlay = singleOverlay
    }
    
    private func setupGroupRequestOverlay(for experience: Experience) {
        
        if overlay is ExperienceRequestGroupMessageViewController {
            return
        }
        removeOverlay()
        
        let groupOverlay = ExperienceRequestGroupMessageViewController()
        addViewController(groupOverlay)
        view.setNeedsLayout()
        
        groupOverlay.setup(for: experience)
        groupOverlay.done = { [weak self] in
            self?.requested?()
        }
        
        self.overlay = groupOverlay
    }
    
    private func setupClaimRequestOverlay(for experience: Experience) {
        
        if overlay is ExperienceRequestClaimMessageViewController {
            return
        }
        removeOverlay()
        
        let claimOverlay = ExperienceRequestClaimMessageViewController()
        addViewController(claimOverlay)
        view.setNeedsLayout()
        
        claimOverlay.setup(for: experience)
        claimOverlay.done = { [weak self] in
            self?.requested?()
        }
        claimOverlay.error = { [weak self] errorMsg in
            let alert = UIAlertController(title: "Error happened", message: errorMsg ?? "Unable to perform the action at the moment, please try again.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                self?.back?()
            }))
            self?.present(alert, animated: true, completion: nil)
        }
        
        self.overlay = claimOverlay
    }
    
    private func setupDeleteOverlay(for experience: Experience) {
        
        if overlay is ExperienceDeleteViewController {
            return
        }
        removeOverlay()
        
        let deleteOverlay = ExperienceDeleteViewController()
        addViewController(deleteOverlay)
        view.setNeedsLayout()
        
        deleteOverlay.setup(for: experience)
        deleteOverlay.deleted = { [weak self] in
            self?.deleted?()
        }
        deleteOverlay.activated = { [weak self] post in
            self?.activated?(post)
        }
        
        self.overlay = deleteOverlay
    }
    
    private func setupTierOverlay(for experience: Experience) {
        
        if overlay is ExperienceTierViewController {
            return
        }
        removeOverlay()
        
        let tierOverlay = ExperienceTierViewController()
        addViewController(tierOverlay)
        view.setNeedsLayout()
        
        tierOverlay.setup(for: experience)
        tierOverlay.profile = { [weak self] in
            let now = Date()
            if let post = experience.activePost() {
                self?.presentUser(post.creator.id)
            }
        }
        tierOverlay.chat = { [weak self] in
            self?.chat?()
        }
        tierOverlay.done = { [weak self] in
            self?.requested?()
        }
        
        self.overlay = tierOverlay
    }
}

extension ExperienceDetailsNavigationController {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? ProfileViewController {
            vc.bottomPadding = bottomPadding
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let vc = viewController as? ProfileViewController {
            vc.scrolling = { [weak self] in
                self?.overlay?.fullyCollapse()
            }
        }
    }
}

extension ExperienceDetailsNavigationController: ExperienceDetailsView {
    
    var experience: Experience? {
        guard let vc = navigation.viewControllers.first(where: { $0 is ExperienceDetailsViewController }) as? ExperienceDetailsViewController else {
            return nil
        }
        return vc.experience
    }
    
    var photoFrame: CGRect {
        guard let vc = navigation.viewControllers.first(where: { $0 is ExperienceDetailsViewController }) as? ExperienceDetailsViewController else {
            return .zero
        }
        return vc.photoFrame
    }
    
    var overlaySnapshot: UIImage? {
        let overlay = self.overlay?.view
        var shot: UIImage? = nil
        if let overlay = overlay {
            let backgroundColor = overlay.backgroundColor
            overlay.backgroundColor = .clear
            shot = UIImage.snapshotImage(from: overlay, afterScreenUpdates: true)
            overlay.backgroundColor = backgroundColor
        }
        return shot
    }
    
    func prepareToPresentSignalDetails(size: CGSize) -> CGRect {
        guard let vc = navigation.viewControllers.first(where: { $0 is ExperienceDetailsViewController }) as? ExperienceDetailsViewController else {
             return CGRect(origin: .zero, size: size)
        }
        return vc.prepareToPresentSignalDetails(size: size)
    }
    
    func prepareToDismissSignalDetails(duration: TimeInterval, complete: @escaping (_ frame: CGRect, _ overlaySnapshot: UIImage?) -> ()) {
        
        guard let vc = navigation.viewControllers.first(where: { $0 is ExperienceDetailsViewController }) as? ExperienceDetailsViewController else {
            complete(view.bounds, nil)
            return
        }
        
        let overlayShot = overlaySnapshot
        
        vc.prepareToDismissSignalDetails(duration: duration, complete: { (frame, _) in
            complete(frame, overlayShot)
        })
    }
}


class SignalDetailsNavigation: UINavigationController, ExperienceDetailsView {
    
    var experience: Experience? {
        guard let details = viewControllers.first as? ExperienceDetailsNavigationController else {
            return nil
        }
        return details.experience
    }
    
    var photoFrame: CGRect {
        guard let details = viewControllers.first as? ExperienceDetailsNavigationController else {
            return .zero
        }
        return details.photoFrame
    }
    
    var overlaySnapshot: UIImage? {
        guard let details = viewControllers.first as? ExperienceDetailsNavigationController else {
            return nil
        }
        return details.overlaySnapshot
    }
    
    func prepareToPresentSignalDetails(size: CGSize) -> CGRect {
        guard let details = viewControllers.first as? ExperienceDetailsNavigationController else {
            return CGRect(origin: .zero, size: size)
        }
        return details.prepareToPresentSignalDetails(size: size)
    }
    
    func prepareToDismissSignalDetails(duration: TimeInterval, complete: @escaping (_ frame: CGRect, _ overlaySnapshot: UIImage?)->()) {
        guard let details = viewControllers.first as? ExperienceDetailsNavigationController else {
            complete(view.bounds, nil)
            return
        }
        details.prepareToDismissSignalDetails(duration: duration, complete: complete)
    }
    
}

/*
extension SignalDetailsNavigationController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let vc = navigation.viewControllers.first(where: { $0 is ExperienceDetailsViewController }) as? ExperienceDetailsViewController else {
            return nil
        }
        return vc.animationController(forDismissed: dismissed)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let vc = navigation.viewControllers.first(where: { $0 is ExperienceDetailsViewController }) as? ExperienceDetailsViewController else {
            return nil
        }
        return vc.interactionControllerForDismissal(using: animator)
    }
}
*/
