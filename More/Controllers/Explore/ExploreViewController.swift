//
//  ExploreViewController.swift
//  More
//
//  Created by Luko Gjenero on 09/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI
import FirebaseAuth
import IGListKit
import Firebase

class ExploreViewController: MoreBaseViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    private static let cellIdentifier = "ExploreCollectionViewCell"
    
    @IBOutlet private weak var topBar: ExploreTopBar!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var newSignals: UIButton!
    @IBOutlet private weak var emptyView: ExploreEmptyView!
    @IBOutlet private weak var create: ExploreCreateView!
    
    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    private var dataSource: ExploreListAdapter!
    private let fullSignalTransition = ExperienceDetailsTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set edgesForExtendedLayout to extend under the status bar
        edgesForExtendedLayout = .all
        
        topBar.profileTap = { [weak self] experience in
            self?.showProfile(for: experience)
        }
        
        adapter.collectionView = collectionView
        
        dataSource = ExploreListAdapter(adapter: adapter)
        
        dataSource.selected = { [weak self] (experience) in
            self?.itemSelected(experience: experience)
            self?.reportExperienceExpanded(experience)
        }
        
        dataSource.liked = { (experience) in
            ExperienceService.shared.likeExperience(experience: experience, completion: nil)
        }
        
        dataSource.disliked = { (experience) in
            ExperienceService.shared.dislikeExperience(experience: experience, completion: nil)
        }
        
        dataSource.creator = { [weak self] (experience) in
            let root = self?.navigationController ?? self
            root?.presentUser(experience.creator.id)
        }
        
        dataSource.reload = { [weak self] in
            self?.updateTopBar()
            self?.updateEmptyView()
            self?.checkCenterCell()
        }
        
        dataSource.scrolled = { [weak self] in
            self?.refreshTopBar(scrollOffset: self?.collectionView.contentOffset.x ?? 0)
            if self?.newSignals.isHidden == false && self?.newSignals.layer.animationKeys() == nil {
                self?.hideNewSignals(in: 5)
            }
            self?.checkCenterCell()
        }
        
        dataSource.newSignals = { [weak self] in
            self?.showNewSignalsIfNecessary()
        }
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        // hide new signals button
        newSignals.backgroundColor = .clear
        newSignals.isHidden = true
        newSignals.roundCorners(corners: .allCorners, radius: 20, background: .white, shadow: .black)
        
        //  expand signal details
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
        pan.delegate = self
        pan.cancelsTouchesInView = true
        collectionView.addGestureRecognizer(pan)
        // collectionView.delaysContentTouches = false
 
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        create.tap = { [weak self] in
            LocationService.shared.requestAlways()
            let vc = CreateSignalViewController()
            vc.cancelTap = {
                self?.dismiss(animated: true, completion: nil)
            }
            vc.finished = { (experience, claimed) in
                self?.dismiss(animated: true, completion: {
                    if claimed {
                        self?.requested(for: experience)
                    }
                })
            }
            self?.present(vc, animated: true, completion: nil)
            vc.presentationController?.delegate = self
            // self?.presentationController?.delegate = self
        }
        
        // setup the deeplinking
        DeepLinkService.shared.rootView = navigationController as? MoreTabBarNestedNavigationController
        
        // mock
        // mockNewSignals()
    }
    
    deinit {
        // release the deeplinking
        DeepLinkService.shared.rootView = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemSize = dataSource.cellSize
            if itemSize.width != layout.itemSize.width || itemSize.height != itemSize.height {
                layout.itemSize = itemSize
                collectionView.collectionViewLayout.invalidateLayout()
                // collectionView.reloadData()
                adapter.reloadData(completion: nil)
                updateEmptyView()
            }
        }
    }
    
    private var isFirst: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
//
//            if let ex = self?.dataSource.experiences.first {
//                self?.presentJoinedVirtualBubble(for: ex)
//            }
//
//        }
        
        guard isFirst else { return }
        isFirst = false
        
        // test()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let nc = navigationController as? MoreTabBarNestedNavigationController {
            nc.hideNavigation(hide: false, animated: false)
        }
        
        // test
        setupTest()
        checkCenterCell()
        
        guard isFirst else { return }
        
        setupNavigationBar()
    }
    
    private var settingsShowing: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return settingsShowing
    }
    
    @objc private func toForeground() {
        adapter.reloadData(completion: nil)
    }
    
    // MARK: - Selection
    
    private func itemSelected(experience: Experience) {
        let vc = ExperienceDetailsNavigationController()
        vc.back = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.share = { [weak vc] in
            LinkService.shareExperienceLink(experience: experience, complete: { (url) in
                guard let vc = vc else { return }
                ShareService.shareSignal(link: url, from: vc, complete: { success in
                    if success {
                        ExperienceService.shared.shareExperience(experience: experience, completion: nil)
                    }
                })
            })
        }
        vc.edit = { [weak self] in
            self?.editOrDelete(experience)
        }
        vc.report = { [weak vc] in
            vc?.report(experience)
        }
        vc.requested = { [weak self] in
            self?.dismiss(animated: true, completion: {
                guard !TutorialService.shared.shouldShow(tutorial: .timer),
                    !TutorialService.shared.currentlyShowing(tutorial: .timer)
                    else { return }
                self?.requested(for: experience)
            })
        }
        vc.deleted = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.claimed = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.chat = { [weak self] in
            guard let chat = experience.activePost()?.chat else { return }
            ChatService.shared.getChat(chatId: chat.id) { (chat) in
                guard let chat = chat else { return }
                self?.dismiss(animated: true, completion: {
                    let vc = ChatViewController()
                    _ = vc.view
                    vc.setup(chat: chat)
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
        _ = vc.view

        vc.setup(for: experience)

        let nc = SignalDetailsNavigation(rootViewController: vc)
        nc.setNavigationBarHidden(true, animated: false)
        nc.modalPresentationStyle = .fullScreen
        nc.transitioningDelegate = fullSignalTransition
        present(nc, animated: true, completion: nil)
        nc.enableSwipeToPop()
    }
    
    private func reportExperienceExpanded(_ experience: Experience) {
        Analytics.logEvent("ExperienceExpanded", parameters: ["experienceId": experience.id, "title": experience.title , "text": experience.text])
    }
    
    private func refreshTopBar(scrollOffset: CGFloat) {
        let offset = (scrollOffset + dataSource.padding) / dataSource.cellSize.width * topBar.frame.width
        topBar.contentOffset = CGPoint(x: offset, y: 0)
    }
    
    // MARK: - pull up to show the signal details
    
    private var currentCell: ExploreCollectionViewCell? {
        let idx = Int(round((collectionView.contentOffset.x  + collectionView.contentInset.left) / dataSource.cellSize.width))
        return cell(for: idx)
    }
    
    private func cell(for index: Int) -> ExploreCollectionViewCell? {
        guard index >= 0 && index < dataSource.filteredExperiences.count else { return nil }
        return collectionView.cellForItem(at: IndexPath(item: 0, section: index)) as? ExploreCollectionViewCell
    }
    
    @objc private func pan(sender: UIPanGestureRecognizer) {

        guard dataSource.panEnabled else { return }
        guard collectionView.layer.animationKeys() == nil else { return }
        guard !collectionView.isDecelerating && !collectionView.isDragging else { return }
        
        guard let card = currentCell else { return }
        guard let experience = card.experience else { return }
        
        let offset = sender.translation(in: collectionView).y
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            itemSelected(experience: experience)
            trackPresentInteraction(offset: offset)
        case .changed:
            trackPresentInteraction(offset: offset)
        case .cancelled, .ended, .failed:
            finishPresentInteraction(offset: offset)
        default: ()
        }
    }
    
    private var interactor: Interactor {
        return fullSignalTransition.interactor
    }
    
    private func trackPresentInteraction(offset: CGFloat) {
        if offset < 0 {
            if interactor.hasStarted {
                let top = navigationController?.view.convert(topBar.frame.origin, from: topBar).y ?? topBar.frame.minY
                let progress = min(-offset, top) / top * 0.515
                interactor.update(progress)
            }
        } else {
            if interactor.hasStarted {
                interactor.update(0)
            }
        }
    }
    
    private func finishPresentInteraction(offset: CGFloat) {
        if interactor.hasStarted {
            interactor.hasStarted = false
            if -offset >= topBar.frame.minY * 0.75 {
                interactor.finish()
                
                guard let card = currentCell else { return }
                guard let experience = card.experience else { return }
                reportExperienceExpanded(experience)
            } else {
                interactor.cancel()
            }
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: collectionView)
            let shouldBegin = -translation.y > abs(translation.x)
            return shouldBegin
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /*
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == collectionView.panGestureRecognizer
    }
    */
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == collectionView.panGestureRecognizer
    }
 
    // MARK: - new signals

    private var newSignalsTimer: Timer?

    @IBAction func newSignalsTouch(_ sender: Any) {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        hideNewSignals()
    }
    
    func showNewSignals() {
        
        newSignalsTimer?.invalidate()
        newSignals.alpha = 0
        newSignals.isHidden = false
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.newSignals.alpha = 1
            },
            completion: { (_) in
                // nop
            })
        
        hideNewSignals(in: 15)
    }
    
    func hideNewSignals(in duration: TimeInterval) {
        
        let newFireDate = Date(timeIntervalSinceNow: duration)
        let fireDate = newSignalsTimer?.fireDate ?? newFireDate
        
        guard newFireDate >= fireDate else { return }
        
        newSignalsTimer?.invalidate()
        newSignalsTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] (_) in
            self?.hideNewSignals()
        })
    }
    
    func hideNewSignals() {

        newSignalsTimer?.invalidate()
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.newSignals.alpha = 0
            },
            completion: { (_) in
                self.newSignals.isHidden = true
            })
    }
    
    func showNewSignalsIfNecessary() {
        guard newSignals.isHidden && newSignals.layer.animationKeys() == nil else { return }
        
        if collectionView.contentOffset.x > dataSource.cellSize.width * 3 {
            showNewSignals()
        }
    }
    
    
    /*
    // mock
    
    func mockNewSignals() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (timer) in
            
            guard let sself = self else { timer.invalidate(); return }
            guard sself.newSignals.isHidden && sself.newSignals.layer.animationKeys() == nil else { return }
            
            if sself.collectionView.contentOffset.x > sself.cellSize.width * 3 {
                sself.showNewSignals()
            }
        }
    }
    */
    
    // MARK: - top bar
    
    private func updateTopBar() {
        if dataSource.loading {
            topBar.setup(for: [])
        } else {
            topBar.setup(for: dataSource.filteredExperiences)
        }
    }

    // MARK: - empty view
    
    private func updateEmptyView() {
        let hide = dataSource.loading || dataSource.filteredExperiences.count > 0
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.emptyView.alpha = hide ? 0 : 1
            },
            completion: { (finished) in })
    }
    
    // MARK: - show signal
    
    func showExperience(experience: Experience, check: Bool = false, scroll: Bool = false) {
        dataSource.addExperience(experience, check: check, scroll: scroll)
    }
    
    // MARK: - test
    
    @IBOutlet private weak var topBarVariation: ExperienceTopBarNearbyVersion!
    
    private func setupTest() {
        if ConfigService.shared.experienceTopBarVariation {
            topBarVariation.setup()
            topBarVariation.isHidden = false
            topBarVariation.alpha = 0
            topBar.isHidden = false
        } else {
            topBarVariation.isHidden = true
            topBar.isHidden = false
        }
    }
    
    // MARK: - show the timer on cards
    
    private func checkCenterCell() {
        guard !dataSource.filteredExperiences.isEmpty else { topBarVariation.alpha = 0; return }
        guard let cell = currentCell else { return }
        let offset = collectionView.contentOffset.x + collectionView.contentInset.left
        
        // countdown & tutorials
        if offset.truncatingRemainder(dividingBy: dataSource.cellSize.width) == 0 {
            cell.shownOnTop()
            runTutorials(cell: cell)
        }
        
        // variant
        let floatIndex = offset / dataSource.cellSize.width
        let fraction = floatIndex.truncatingRemainder(dividingBy: 1)
        let index = Int(floatIndex)
        var alpha: CGFloat = 0
        let hideLeft = ExperienceTrackingService.shared.updatedExperienceData(for: self.cell(for: index)?.experience?.id ?? "xx")?.activePost() != nil
        let hideRight = ExperienceTrackingService.shared.updatedExperienceData(for: self.cell(for: index + 1)?.experience?.id ?? "xx")?.activePost() != nil
        if hideLeft {
            if hideRight {
               alpha = 0
            } else {
                alpha = max(0, min(1, (fraction - 0.8) * 5))
            }
        } else {
            if hideRight {
                alpha = max(0, min(1, ((1 - fraction) - 0.8) * 5))
            } else {
                alpha = 1
            }
        }
        topBarVariation.alpha = alpha
    }
    
    // MARK: - show profile
    private func showProfile(for experience: Experience) {
        let users = experience.activeGroup()
        let root = navigationController ?? self
        if users.count > 1 {
            root.presentGroup(users)
        } else if let user = users.first {
            root.presentUser(user.id)
        }
    }
    
    private func editOrDelete(_ experience: Experience) {
        let alert = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            self?.editExperience(experience)
        })
        
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteExperience(experience)
        })
        
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        presentedViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func editExperience(_ experience: Experience) {
        guard let nc = presentedViewController as? SignalDetailsNavigation else { return }
        
        LocationService.shared.requestAlways()
        let vc = CreateSignalViewController()
        vc.cancelTap = { [weak nc] in
            nc?.dismiss(animated: true, completion: nil)
        }
        vc.finished = { [weak self] (experience, claimed) in
            self?.dismiss(animated: true, completion: {
                if claimed {
                    self?.requested(for: experience)
                }
            })
        }
        _ = vc.view
        vc.setup(for: experience)
        nc.present(vc, animated: true, completion: nil)
        vc.presentationController?.delegate = self
    }
    
    private func deleteExperience(_ experience: Experience) {
        let alert = UIAlertController(title: "Delete This Time?", message: "This will delete this Time everywhere in the app and cannot be undone.", preferredStyle: .alert)
        
        let report = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.executeDeleteExperience(experience)
        })
        
        alert.addAction(report)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        presentedViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func executeDeleteExperience(_ experience: Experience) {
        presentedViewController?.showLoading()
        ExperienceService.shared.deleteExperience(experienceId: experience.id) { [weak self] (success, errorMsg) in
            self?.presentedViewController?.hideLoading()
            if success {
                self?.dismiss(animated: true, completion: {
                    self?.dataSource.removeExperience(id: experience.id)
                })
            }
        }
    }
    
    // MARK: - tutorials
    private func runTutorials(cell: ExploreCollectionViewCell) {
        // check the tutorials
        if let nc = navigationController {
            if TutorialService.shared.shouldShow(tutorial: .firstCard) {
                let anchor =  cell.convert(CGPoint(x: cell.bounds.midX, y: 0), to: nc.view)
                TutorialService.shared.show(tutorial: .firstCard, anchor: anchor, container: nc.view, above: true)
            } else if TutorialService.shared.shouldShow(tutorial: .secondCard) {
                let anchor =  cell.convert(CGPoint(x: cell.bounds.midX, y: 0), to: nc.view)
                TutorialService.shared.show(tutorial: .secondCard, anchor: anchor, container: nc.view, above: true)
            } else if TutorialService.shared.shouldShow(tutorial: .timer),
                let experience = ExperienceTrackingService.shared.updatedExperienceData(for: cell.experience?.id ?? "xx"),
                experience.activePost()?.creator.isMe() == true {
                let anchor =  cell.convert(CGPoint(x: cell.bounds.midX, y: 20), to: nc.view)
                TutorialService.shared.show(tutorial: .timer, anchor: anchor, container: nc.view, above: true)
            } else if TutorialService.shared.shouldShow(tutorial: .people),
                let experience = ExperienceTrackingService.shared.updatedExperienceData(for: cell.experience?.id ?? "xx"),
                let post = experience.activePost(), !post.creator.isMe() {
                let anchor =  topBarVariation.convert(CGPoint(x: 50, y: topBarVariation.frame.height - 20), to: nc.view)
                TutorialService.shared.show(tutorial: .people, anchor: anchor, container: nc.view, above: false)
            } else if TutorialService.shared.shouldShow(tutorial: .active),
                let experience = ExperienceTrackingService.shared.updatedExperienceData(for: cell.experience?.id ?? "xx"),
                experience.activePost() == nil {
                let anchor =  topBarVariation.convert(CGPoint(x: 50, y: topBarVariation.bounds.height - 20), to: nc.view)
                TutorialService.shared.show(tutorial: .active, anchor: anchor, container: nc.view, above: false)
            }
        }
    }
    
}

extension ExploreViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let vc = presentationController.presentedViewController as? CreateSignalViewController {
            vc.save()
        }
    }    
}

extension ExploreViewController: ExperienceDetailsPresenter {
   
    fileprivate var topCard: ExploreCollectionViewCell? {
        var card: ExploreCollectionViewCell? = nil
        let idx = Int(round((collectionView.contentOffset.x  + collectionView.contentInset.left) / dataSource.cellSize.width))
        if idx >= 0 && idx < dataSource.filteredExperiences.count {
            card = collectionView.cellForItem(at: IndexPath(item: 0, section: idx)) as? ExploreCollectionViewCell
        }
        return card
    }
    
    var signalCell: ExploreCollectionViewCell? {
        return topCard
    }
    
    var topSignalBar: ExploreTopBar? {
        return topBar
    }
    
    var topBarSnapshot: UIImage? {
        if let cell = topBar.visibleCells.first {
            return UIImage.snapshotImage(from: cell, afterScreenUpdates: true)
        }
        return nil
    }
    
    var bottomPadding: CGFloat {
        return tabBarController?.view.safeAreaInsets.bottom ?? 0
    }
    
    func pause() {
        topCard?.pause()
        
    }
       
    func start() {
        topCard?.start()
    }
}

extension MoreTabBarNestedNavigationController: ExperienceDetailsPresenter {
    
    var signalCell: ExploreCollectionViewCell? {
        let explore = topViewController as? ExploreViewController
        return explore?.signalCell
    }
    
    var topSignalBar: ExploreTopBar? {
        let explore = topViewController as? ExploreViewController
        return explore?.topSignalBar
    }
    
    var topBarSnapshot: UIImage? {
        let explore = topViewController as? ExploreViewController
        return explore?.topBarSnapshot
    }
    
    var bottomPadding: CGFloat {
        let explore = topViewController as? ExploreViewController
        return explore?.bottomPadding ?? 0
    }
    
    func pause() {
        let explore = topViewController as? ExploreViewController
        explore?.pause()
    }
       
    func start() {
        let explore = topViewController as? ExploreViewController
        explore?.start()
    }
}



// MARK: - PN tests

extension ExploreViewController {
    
    func test() {
        
        // testNewPostNotification()
        
        // testNewLikeNotification()
    }
    
    private func testNewPostNotification() {
        let content = UNMutableNotificationContent()
        content.title = "New post"
        content.body = "Testing ..."
        content.userInfo["type"] = "newPost"
        content.userInfo["experienceId"] = "q8Ob7jY4yLSNbRzjSOHh"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
    
    private func testNewLikeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "New like"
        content.body = "Testing ..."
        content.userInfo["type"] = "newLike"
        content.userInfo["experienceId"] = "VPE73nFHf60EXr7aw6De"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
}

