//
//  PastExperiencesViewController.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import IGListKit

class PastExperiencesViewController: MoreBaseViewController {

    private static let cellIdentifier = "ExploreCollectionViewCell"
        
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var emptyView: ExploreEmptyView!
    
    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    private var dataSource: PastListAdapter!
    private let fullSignalTransition = ExperienceDetailsTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter.collectionView = collectionView
        
        dataSource = PastListAdapter(adapter: adapter)
        
        dataSource.selected = { [weak self] (experience) in
            self?.itemSelected(experience: experience)
        }
        
        dataSource.reload = { [weak self] in
            self?.updateEmptyView()
        }
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        emptyView.isHidden = true
        emptyView.setupForDesignedExperiences()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemSize = dataSource.cellSize
            if itemSize.width != layout.itemSize.width || itemSize.height != itemSize.height {
                layout.itemSize = itemSize
                collectionView.collectionViewLayout.invalidateLayout()
                adapter.reloadData(completion: nil)
            }
        }
    }
    
    private var isFirst: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirst else { return }
        isFirst = false
        
        dataSource.startTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let nc = navigationController as? MoreTabBarNestedNavigationController {
            nc.hideNavigation(hide: false, animated: false)
        }
        
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
    
    private func setupNavigationBar() {
        setTitle("Past Times")
    }
    
    // MARK: - Selection
    
    private func itemSelected(experience: Experience) {
        // do we want to show this ??
        
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
        vc.deleted = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        _ = vc.view
        
        vc.setupForOwn(experience)
        
        let nc = SignalDetailsNavigation(rootViewController: vc)
        nc.setNavigationBarHidden(true, animated: false)
        nc.modalPresentationStyle = .popover
        present(nc, animated: true, completion: nil)
        nc.enableSwipeToPop()
    }
    
    // MARK: - empty view
    
    private func updateEmptyView() {
        let hide = dataSource.experiences.count > 0
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.emptyView.alpha = hide ? 0 : 1
            },
            completion: { (finished) in })
    }
    
    // MARK: - show signal
    
    func showExperience(experience: Experience) {
        dataSource.addExperience(experience)
        adapter.scroll(to: experience, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: false)
    }
}

extension PastExperiencesViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let vc = presentationController.presentedViewController as? CreateSignalViewController {
            vc.save()
        }
    }
}
