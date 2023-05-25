//
//  ExperienceDetailsViewController.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let photosCell = String(describing: SignalDetailsPhotosCell.self)
private let quoteCell = String(describing: SignalDetailsQuoteCell.self)
private let likesCell = String(describing: SignalDetailsLikesCell.self)
private let userCell = String(describing: SignalDetailsUserCell.self)
private let tipsCell = String(describing: SignalDetailsTipsCell.self)
private let mapCell = String(describing: SignalDetailsMapCell.self)

class ExperienceDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var like: UIButton!
    @IBOutlet private weak var share: UIButton!
    @IBOutlet private weak var more: UIButton!
    @IBOutlet private weak var moreWidth: NSLayoutConstraint!
    @IBOutlet private weak var headerBackgorund: UIView!
    @IBOutlet private weak var topFade: FadeView!
    
    private(set) var experience: Experience?
    private var rows: [String] = []
    var liked: Bool = false {
        didSet {
            updateUI(tableView)
        }
    }
    
    var backTap: (()->())?
    var shareTap: (()->())?
    var moreTap: (()->())?
    var scrolling: (()->())?
    
    var bottomPadding: CGFloat = 90 {
        didSet {
            updateInsets()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        back.enableShadow(color: .black)
        share.enableShadow(color: .black)
        more.enableShadow(color: .black)
        
        more.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        
        topFade.orientation = .up
        topFade.color = UIColor.black.withAlphaComponent(0.5)
        headerBackgorund.alpha = 0
        
        back.layer.transform = CATransform3DMakeRotation(-CGFloat.pi * 0.5, 0, 0, 1)

        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UINib(nibName: photosCell, bundle: nil), forCellReuseIdentifier: photosCell)
        tableView.register(UINib(nibName: quoteCell, bundle: nil), forCellReuseIdentifier: quoteCell)
        tableView.register(UINib(nibName: likesCell, bundle: nil), forCellReuseIdentifier: likesCell)
        tableView.register(UINib(nibName: userCell, bundle: nil), forCellReuseIdentifier: userCell)
        tableView.register(UINib(nibName: tipsCell, bundle: nil), forCellReuseIdentifier: tipsCell)
        tableView.register(UINib(nibName: mapCell, bundle: nil), forCellReuseIdentifier: mapCell)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        share.alpha = 0
        like.alpha = 0
        
        // determine and act on whether or not the Map Cell is showing.
        var isMapCellVisible: Bool = false
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateInsets()
    }
    
    private func updateInsets() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom + bottomPadding, right: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.reloadData()
    }

    @IBAction func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction func likeTouch(_ sender: Any) {
        guard ConfigService.shared.canRemoveLike || !liked else { return }
        guard let experience = experience else { return }
        liked = !liked
        if liked {
            ExperienceService.shared.likeExperience(experience: experience, completion: nil)
        } else {
            ExperienceService.shared.dislikeExperience(experience: experience, completion: nil)
        }
        var likes = experience.numOfLikes ?? 0
        likes += liked ? 1 : -1
        let updatedExperience = experience.experienceWithNumOfLikes(likes)
        setup(for: updatedExperience)
    }
    
    @IBAction func shareTouch(_ sender: Any) {
        shareTap?()
    }
    
    @IBAction func moreTouch(_ sender: Any) {
        moreTap?()
    }
    
    func setup(for experience: Experience) {
        self.experience = experience
        
//        if experience.creator.isMe() {
//            more.isHidden = true
//            moreWidth.constant = 0
//        }
        
        ExperienceService.shared.haveLikedExperience(experienceId: experience.id) { [weak self] (liked, _) in
            if let liked = liked {
                self?.liked = liked
            }
        }
        
        rows = []
        
        if SignalDetailsPhotosCell.isShowing(for: experience) {
            rows.append(photosCell)
        }
        if SignalDetailsQuoteCell.isShowing(for: experience) {
            rows.append(quoteCell)
        }
        if SignalDetailsLikesCell.isShowing(for: experience) {
            rows.append(likesCell)
        }
        if SignalDetailsUserCell.isShowing(for: experience) {
            rows.append(userCell)
        }
        if SignalDetailsTipsCell.isShowing(for: experience) {
            rows.append(tipsCell)
        }
        if SignalDetailsMapCell.isShowing(for: experience) {
            rows.append(mapCell)
        }
        
        tableView.reloadData()
    }
    
    func scrollToTop(animated: Bool) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: animated)
    }
    
    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = rows[indexPath.row]
        if let experience = experience,
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SignalDetailsBaseCell {
            
            if let cell = cell as? SignalDetailsPhotosCell {
                cell.scrolling = { [weak self] in
                    self?.scrolling?()
                }
                cell.share = { [weak self] in
                    guard let share = self?.share else { return }
                    self?.shareTouch(share)
                }
                cell.like = { [weak self] in
                    guard let like = self?.like else { return }
                    self?.likeTouch(like)
                }
                cell.creator = { [weak self] in
                    self?.showProfile()
                }
            }
            if let cell = cell as? SignalDetailsUserCell {
                cell.viewProfile = { [weak self] in
                    self?.showProfile()
                }
                cell.follow = { [weak self] in
                    let alert = UIAlertController(title: "Missing action", message: "Need to add action for this", preferredStyle: .alert)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            
            if let cell = cell as? SignalDetailsTipsCell {
                cell.add = { [weak self] in
                    let vc = CreateExperienceTipViewController()
                    vc.cancel = {
                        self?.dismiss(animated: true, completion: nil)
                    }
                    vc.done = { text in
                        self?.dismiss(animated: true, completion: {
                            self?.addTip(text)
                        })
                    }
                    self?.present(vc, animated: true, completion: nil)
                }
                cell.upvoteTip = { [weak self] tip in
                    self?.upvoteTip(tip)
                }
                cell.downvoteTip = { [weak self] tip in
                    self?.downvoteTip(tip)
                }
            }
            
            
            cell.setup(for: experience)
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = rows[indexPath.row]
        if identifier == likesCell {
            showLikes()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrolling?()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUI(scrollView)
        trackDismissInteraction(offset: -scrollView.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        finishDismissInteraction(offset: -scrollView.contentOffset.y)
    }
    
    // MARK: - handle scrolling UI
    
    private func updateUI(_ scrollView: UIScrollView) {
        let headerBreak = tableView.frame.width * SignalDetailsPhotosCell.photoAspect - view.safeAreaInsets.top
        let progress = min(1, max(0, (scrollView.contentOffset.y - headerBreak) / 50))
        headerBackgorund.alpha = progress
        
        let color = UIColor.whiteTwo.interpolateRGB(to: .blueGrey, fraction: progress)
        back.tintColor = color
        share.tintColor = color
        more.tintColor = color
        like.tintColor = liked ? UIColor.fireEngineRed : color
        
        let alpha = floor(progress)
        share.alpha = alpha
        like.alpha = alpha
    }
    
    // MARK: - tips
    
    private func addTip(_ text: String) {
        guard let experience = experience else { return }
        guard let me = ProfileService.shared.profile?.shortUser else { return }
        
        let tip = ExperienceTip(creator: me, createdAt: Date(), text: text, upvote: nil, downvote: nil)
        
        ExperienceService.shared.addExperienceTip(experienceId: experience.id, tip: tip) { [weak self] (tip, _) in
            if let tip = tip {
                guard let experience = self?.experience else { return }
                var updatedTips = experience.tips ?? []
                updatedTips.append(tip)
                self?.setup(for: experience.experienceWithTips(updatedTips))
            }
        }
    }
    
    private func upvoteTip(_ tip: ExperienceTip) {
        guard let experience = experience else { return }
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        ExperienceService.shared.upvoteExperienceTip(experienceId: experience.id, tipId: tip.id) { [weak self] (success, _) in
            if success {
                guard let experience = self?.experience else { return }
                var upvote = tip.upvote ?? []
                upvote.append(myId)
                let updatedTip = tip.tipWithVotes(upvote: upvote, downvote: tip.downvote)
                var updatedTips = experience.tips ?? []
                if let idx = updatedTips.firstIndex(of: tip) {
                    updatedTips.remove(at: idx)
                    updatedTips.insert(updatedTip, at: idx)
                }
                self?.setup(for: experience.experienceWithTips(updatedTips))
            }
        }
    }
    
    private func downvoteTip(_ tip: ExperienceTip) {
        guard let experience = experience else { return }
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        ExperienceService.shared.downvoteExperienceTip(experienceId: experience.id, tipId: tip.id) { [weak self] (success, _) in
            if success {
                guard let experience = self?.experience else { return }
                var downvote = tip.downvote ?? []
                downvote.append(myId)
                let updatedTip = tip.tipWithVotes(upvote: tip.upvote, downvote: downvote)
                var updatedTips = experience.tips ?? []
                if let idx = updatedTips.firstIndex(of: tip) {
                    updatedTips.remove(at: idx)
                    updatedTips.insert(updatedTip, at: idx)
                }
                self?.setup(for: experience.experienceWithTips(updatedTips))
            }
        }
    }

    
    // MARK: - details views
    
    private func showProfile() {
        guard let experience = experience else { return }
        
        let userId = experience.creator.id
        navigationController?.showLoading()
        ProfileService.shared.loadProfile(withId: userId) { [weak self] (user, errorMsg) in
            self?.navigationController?.hideLoading()
            if let user = user {
                let vc = ProfileViewController()
                vc.backTap = {
                    self?.navigationController?.popViewController(animated: true)
                }
                vc.moreTap = { [weak self] in
                    self?.moreTap?()
                }
                _ = vc.view
                vc.setup(for: UserViewModel(profile: user))
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func showReviews() {
        guard let experience = experience else { return }
        
        let userId = experience.posts?.first?.creator.id ?? experience.creator.id
        navigationController?.showLoading()
        ProfileService.shared.loadProfile(withId: userId) { [weak self] (user, errorMsg) in
            self?.navigationController?.hideLoading()
            if let user = user {
                let vc = ReviewsViewController()
                vc.backTap = {
                    self?.navigationController?.popViewController(animated: true)
                }
                _ = vc.view
                vc.setup(for: UserViewModel(profile: user))
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func showLikes() {
        guard let experience = experience else { return }

        let vc = ExperienceLikesViewController()
        vc.backTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        _ = vc.view
        vc.setup(for: experience)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - pull down to dismiss
    
    private var finishingDismiss = false
    
    private var interactor: Interactor? {
        if let root = navigationController?.parent?.navigationController,
            let transitionDelegate = root.transitioningDelegate as? ExperienceDetailsTransitioningDelegate {
            return transitionDelegate.interactor
        }
        return nil
    }
    
    private func trackDismissInteraction(offset: CGFloat) {
        guard let interactor = interactor else { return }
        
        if finishingDismiss {
            if offset <= 0 {
                finishingDismiss = false
            }
            return
        }
        
        guard interactor.hasStarted || !tableView.isDecelerating else { return }
        
        if offset > 0 {
            if !interactor.hasStarted {
                interactor.hasStarted = true
                backTap?()
            }
            interactor.update(min(offset, 150) / 150 * 0.515)
        } else {
            if interactor.hasStarted {
                interactor.hasStarted = false
                interactor.cancel()
            }
        }
    }
    
    private func finishDismissInteraction(offset: CGFloat) {
        guard let interactor = interactor else { return }
        if interactor.hasStarted {
            interactor.hasStarted = false
            if offset >= 80 {
                interactor.finish()
            } else {
                interactor.cancel()
                
                // kill off bouncing back
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak tableView] in
                    tableView?.bounces = false
                    tableView?.setContentOffset(.zero, animated: false)
                    tableView?.bounces = true
                }
            }
            finishingDismiss = true
        }
    }
}

extension ExperienceDetailsViewController: ExperienceDetailsView {

    var photoFrame: CGRect {
        var rect = CGRect(
            origin: .zero,
            size: CGSize(width: tableView.bounds.width, height: tableView.bounds.width * SignalDetailsPhotosCell.photoAspect))
        rect.origin.y -= tableView.contentOffset.y
        return rect
    }
    
    var overlaySnapshot: UIImage? {
        return nil
    }
    
    func prepareToPresentSignalDetails(size: CGSize) -> CGRect {
        return CGRect(
            origin: .zero,
            size: CGSize(width: size.width, height: size.width * SignalDetailsPhotosCell.photoAspect))
    }
    
    func prepareToDismissSignalDetails(duration: TimeInterval, complete: @escaping (_ frame: CGRect, _ overlaySnapshot: UIImage?) -> ()) {
        
        let rect = CGRect(
            origin: .zero,
            size: CGSize(width: tableView.bounds.width, height: tableView.bounds.width * SignalDetailsPhotosCell.photoAspect))
        
        if tableView.contentOffset.y > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                complete(rect, nil)
            }
        } else {
            complete(rect, nil)
        }
    }
}



