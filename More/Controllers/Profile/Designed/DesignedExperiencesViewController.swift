//
//  DesignedExperiencesViewController.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import IGListKit

class DesignedExperiencesViewController: MoreBaseViewController {

    private static let cellIdentifier = "ExploreCollectionViewCell"
        
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var emptyView: ExploreEmptyView!
    @IBOutlet private weak var create: ExploreCreateView!
    
    private lazy var adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    private var dataSource: DesignedListAdapter!
    private let fullSignalTransition = ExperienceDetailsTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter.collectionView = collectionView
        
        dataSource = DesignedListAdapter(adapter: adapter)
        
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
        
        create.tap = { [weak self] in
            LocationService.shared.requestAlways()
            let vc = CreateSignalViewController()
            vc.cancelTap = {
                self?.dismiss(animated: true, completion: nil)
            }
            vc.finished = { (experience, claimed) in
                self?.dismiss(animated: true, completion: {
                    ExperienceService.shared.loadExperience(experienceId: experience.id) { (experience, _) in
                        guard let experience = experience else { return }
                        self?.dataSource.addExperience(experience)
                    }
                    if claimed {
                        self?.requested(for: experience)
                    }
                })
            }
            self?.present(vc, animated: true, completion: nil)
            vc.presentationController?.delegate = self
        }
        
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
        setTitle("Designed Times")
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
        vc.deleted = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        vc.edit = { [weak self] in
            self?.editOrDelete(experience)
        }
        vc.activated = { [weak self] post in
            self?.dataSource.refreshExperience(experience.experienceWithPosts([post]))
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
    
    func showExperience(experienceId: String) {
        dataSource.scrollToExperienceId = experienceId
    }
    
    // MARK: - more options
    
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
        vc.cancelTap = {
            nc.popViewController(animated: true)
        }
        vc.finished = { [weak self] (experience, claimed) in
            self?.dismiss(animated: true, completion: {
                ExperienceService.shared.loadExperience(experienceId: experience.id) { (experience, _) in
                    guard let experience = experience else { return }
                    self?.dataSource.refreshExperience(experience)
                }
                if claimed {
                    self?.requested(for: experience)
                }
            })
        }
        _ = vc.view
        vc.setup(for: experience)
        nc.pushViewController(vc, animated: true)
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
}

extension DesignedExperiencesViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let vc = presentationController.presentedViewController as? CreateSignalViewController {
            vc.save()
        }
    }
}

