//
//  DesignedListAdapter.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

class DesignedListAdapter: NSObject, ListAdapterDataSource {

    let padding: CGFloat = 32
    var cellSize: CGSize {
        if let collectionView = collectionView {
            return CGSize(width: collectionView.frame.width - 2 * padding, height: collectionView.frame.height)
        }
        return .zero
    }
    
    var reload: (()->())?
    var selected: ((_ experience: Experience)->())?
    
    var loaded: Bool = false
    var scrollToExperienceId: String? {
        didSet {
            scrollIfNecessary()
        }
    }
    
    private(set) var experiences: [Experience] = []
    
    private var transitionState: ExploreCollectionViewLayout.TransitionState = .add
    
    private let adapter: ListAdapter
    private(set) var collectionView: UICollectionView?
    private var listener: ListenerRegistration?
    
    init(adapter: ListAdapter) {
        self.adapter = adapter
        super.init()
        adapter.dataSource = self
        collectionView = adapter.collectionView
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView?.delaysContentTouches = false
        
        if let layout = collectionView?.collectionViewLayout as? ExploreCollectionViewLayout {
            layout.exploreCollectionLayoutDelegate = self
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    func addExperience(_ experience: Experience) {
        if experiences.contains(experience) {
            if let idx = experiences.firstIndex(where: { $0.id == experience.id }) {
                experiences.remove(at: idx)
            }
        }
        experiences.insert(experience, at: 0)
        transitionState = .add
        reloadUI()
    }
    
    func removeExperience(id: String) {
        if let idx = experiences.firstIndex(where: { $0.id == id }) {
            experiences.remove(at: idx)
            transitionState = idx >= experiences.count ? .removeEnd : .remove
            reloadUI()
        }
    }
    
    func refreshExperience(_ experience: Experience) {
        if let idx = experiences.firstIndex(where: { $0.id == experience.id }) {
            experiences.remove(at: idx)
            experiences.insert(experience, at: idx)
            transitionState = .refresh
            reloadUI()
        }
    }
    
    private func reloadUI() {
        adapter.performUpdates(animated: true, completion: { [weak self] (_) in
            self?.reload?()
        })
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return experiences
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let object = ExploreSectionController(size: cellSize)
        object.selected = { [weak self] (experience) in
            self?.selected?(experience)
        }
        return object
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        // TODO: - loading
        return nil
    }
    
}

extension DesignedListAdapter {
    
    func startTracking() {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        
        listener =
        Firestore.firestore().collection(ExperienceService.Paths.experiences)
        .whereField("creator.id", isEqualTo: myId)
        .order(by: "createdAt", descending: false)
        .addSnapshotListener({ [weak self] (snapshot, error) in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { diff in
                guard let experience = Experience.fromSnapshot(diff.document) else { return }
                
                switch diff.type {
                case .added:
                    ExperienceService.shared.loadExperience(experienceId: experience.id) { (experience, _) in
                        guard let experience = experience else { return }
                        self?.addExperience(experience)
                    }
                case .removed:
                    self?.removeExperience(id: experience.id)
                case .modified:
                    ()
                }
            }
            
            if self?.loaded == false {
                self?.loaded = true
                self?.adapter.performUpdates(animated: true, completion: { (_) in
                    self?.scrollIfNecessary()
                })
            }
        })
    }
    
    private func scrollIfNecessary() {
        guard loaded else { return }
        guard let experienceId = scrollToExperienceId else { return }
        scrollToExperienceId = nil
        
        if let experience = experiences.first(where: { $0.id == experienceId }) {
            adapter.scroll(to: experience, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: true)
        }
    }
}

extension DesignedListAdapter: ExploreCollectionLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, transitionForItemAt indexPath: IndexPath) -> ExploreCollectionViewLayout.TransitionState {
        
        return transitionState
    }
}
