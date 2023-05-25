//
//  ExploreListAdapter.swift
//  More
//
//  Created by Luko Gjenero on 31/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import IGListKit
import Firebase

class ExploreListAdapter: NSObject, ListAdapterDataSource {

    let padding: CGFloat = 32
    var cellSize: CGSize {
        if let collectionView = collectionView {
            return CGSize(width: collectionView.frame.width - 2 * padding, height: collectionView.frame.height)
        }
        return .zero
    }
    
    var reload: (()->())?
    var newSignals: (()->())?
    var scrolled: (()->())?
    var selected: ((_ experience: Experience)->())?
    var liked: ((_ experience: Experience)->())?
    var disliked: ((_ experience: Experience)->())?
    var creator: ((_ experience: Experience)->())?
    
    private(set) var loading: Bool = true
    private(set) var panEnabled: Bool = true
    private(set) var filterTypes: [SignalType] = []
    private(set) var experiences: [Experience] = []
    private(set) var filteredExperiences: [Experience] = []
    
    private var transitionState: ExploreCollectionViewLayout.TransitionState = .add
    
    private let adapter: ListAdapter
    private(set) var collectionView: UICollectionView?
    
    init(adapter: ListAdapter) {
        self.adapter = adapter
        super.init()
        startTracking()
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        collectionView = adapter.collectionView
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView?.delaysContentTouches = false
        
        if let layout = collectionView?.collectionViewLayout as? ExploreCollectionViewLayout {
            layout.exploreCollectionLayoutDelegate = self
        }
    }
    
    func filter(_ types: [SignalType]) {
        filterTypes = types
        if filterTypes.count > 0 {
            self.filteredExperiences = experiences.filter { filterTypes.contains($0.type) }
        } else {
            self.filteredExperiences = experiences
        }
        reloadUI()
    }
    
    func addExperience(_ experience: Experience, check: Bool = false, scroll: Bool = false) {
        if check && !checkExperience(experience) {
            return
        }
        
        if experiences.contains(experience) {
            if let idx = experiences.firstIndex(where: { $0.id == experience.id }) {
                experiences.remove(at: idx)
            }
            if let idx = filteredExperiences.firstIndex(where: { $0.id == experience.id }) {
                filteredExperiences.remove(at: idx)
            }
        } else {
            ExperienceTrackingService.shared.track(experienceId: experience.id)
            Analytics.logEvent("ExperienceFound", parameters: ["experienceId": experience.id, "title": experience.title , "text": experience.text])
            if let post = experience.activePost() {
                Analytics.logEvent("ExperiencePostFound", parameters: ["experienceId": experience.id, "postId": post.id])
            }
        }
        experiences.insert(experience, at: 0)
        if filterTypes.count == 0 || filterTypes.contains(experience.type) {
            filteredExperiences.insert(experience, at: 0)
            transitionState = .add
            reloadUI(scrollTo: scroll ? experience : nil)
        }
        newSignals?()
    }
    
    func removeExperience(id: String) {
        if let idx = experiences.firstIndex(where: { $0.id == id }) {
            experiences.remove(at: idx)
        }
        if let idx = filteredExperiences.firstIndex(where: { $0.id == id }) {
            filteredExperiences.remove(at: idx)
            transitionState = idx >= filteredExperiences.count ? .removeEnd : .remove
            reloadUI()
        }
    }
    
    func refreshExperience(_ experience: Experience) {
        if let idx = experiences.firstIndex(where: { $0.id == experience.id }) {
            experiences.remove(at: idx)
            experiences.insert(experience, at: idx)
        }
        if let idx = filteredExperiences.firstIndex(where: { $0.id == experience.id }) {
            filteredExperiences.remove(at: idx)
            filteredExperiences.insert(experience, at: idx)
            transitionState = .refresh
            reloadUI()
        }
    }
    
    private func reloadUI(force: Bool = false, scrollTo experience: Experience? = nil) {
        if force {
            adapter.reloadData(completion: { [weak self] (_) in
                self?.reload?()
                if let experience = experience {
                    self?.adapter.scroll(to: experience, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: false)

                }
            })
        } else {
            adapter.performUpdates(animated: true, completion: { [weak self] (_) in
                self?.reload?()
                if let experience = experience {
                    self?.adapter.scroll(to: experience, supplementaryKinds: nil, scrollDirection: .horizontal, scrollPosition: .centeredHorizontally, animated: false)
                }
            })
        }
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        if /* filteredExperiences.count == 0 && */ loading {
            return ["loading" as NSString]
        }
        return filteredExperiences
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let object = ExploreSectionController(size: cellSize)
        object.selected = { [weak self] (experience) in
            self?.selected?(experience)
        }
        object.liked = { [weak self] (experience) in
            self?.liked?(experience)
        }
        object.disliked = { [weak self] (experience) in
            self?.disliked?(experience)
        }
        object.creator = { [weak self] (experience) in
            self?.creator?(experience)
        }
        return object
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        // TODO: - loading
        return nil
    }
    
    private func checkExperience(_ experience: Experience) -> Bool {
        if (experience.isActive() && (experience.isNear() || experience.activePost()?.isNear() == true)) {
            return true
        } else {
            let alert = UIAlertController(title: "Unavailable", message: "The card \"\(experience.title)\" is not available right now.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Got it", style: .default, handler: nil)
            alert.addAction(ok)
            AppDelegate.appDelegate()?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            return false
        }
    }
}


extension ExploreListAdapter {
    
    private func startTracking() {
        NotificationCenter.default.addObserver(self, selector: #selector(experiencesStartLoad(_:)), name: ExperienceService.Notifications.ExperiencesStartLoad, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(experiencesLoaded(_:)), name: ExperienceService.Notifications.ExperiencesLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newExperience(_:)), name: ExperienceService.Notifications.ExperienceEnteredRegion, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(experienceRemoved(_:)), name: ExperienceService.Notifications.ExperienceExitedRegion, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(experienceRemoved(_:)), name: ExperienceTrackingService.Notifications.ExperienceExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(experienceChanged(_:)), name: ExperienceTrackingService.Notifications.ExperienceChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(experienceChanged(_:)), name: ExperienceTrackingService.Notifications.ExperiencePost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(experienceChanged(_:)), name: ExperienceTrackingService.Notifications.ExperiencePostChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(experienceChanged(_:)), name: ExperienceTrackingService.Notifications.ExperiencePostExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(experienceChanged(_:)), name: ExperienceTrackingService.Notifications.ExperienceRequest, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(blocked(_:)), name: ProfileService.Notifications.BlockedLoaded, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reported(_:)), name: ProfileService.Notifications.ReportedLoaded, object: nil)
        
        initialLoad()
    }
    
    private func initialLoad() {
        experiences = []
        filteredExperiences = []
        
        // add already loaded experiences
        let initial = ExperienceService.shared.getExperiences()
        if !initial.isEmpty {
            setExperiences(initial)
        }
    }
    
    private func setExperiences(_ experiences: [Experience]) {
        print("setExperiences'\(experiences.count))")
        loading = false
        self.experiences = experiences
        filteredExperiences = experiences.filter { filterTypes.count == 0 || filterTypes.contains($0.type) }
        reloadUI()
    }
    
    @objc private func experiencesStartLoad(_ notice: Notification) {
        print("experiencesStartLoad")
        DispatchQueue.main.async { [weak self] in
            self?.loading = true
            self?.reloadUI()
        }
    }
    
    @objc private func experiencesLoaded(_ notice: Notification) {
        print("experiencesLoaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.setExperiences(ExperienceService.shared.getExperiences())
        }
    }
    
    @objc private func newExperience(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let experience = notice.userInfo?["experience"] as? Experience,
                !ProfileService.shared.blocked.contains(experience.creator.id),
                !ProfileService.shared.reported.contains(experience.id) {
                self?.addExperience(experience)
            }
        }
    }
    
    @objc private func experienceChanged(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let experience = notice.userInfo?["experience"] as? Experience {
                self?.refreshExperience(experience)
            } else if let experienceId = notice.userInfo?["experienceId"] as? String,
                let experience = ExperienceTrackingService.shared.updatedExperienceData(for: experienceId) {
                self?.refreshExperience(experience)
            }
        }
    }
    
    @objc private func experienceRemoved(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let experienceId = notice.userInfo?["experienceId"] as? String {
                self?.removeExperience(id: experienceId)
            }
        }
    }
    
    @objc private func blocked(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let toRemove = self?.experiences.filter({ ProfileService.shared.blocked.contains($0.creator.id) }).map({ $0.id }),
                !toRemove.isEmpty
                else { return }
            
            toRemove.forEach { self?.removeExperience(id: $0) }
        }
    }
    
    @objc private func reported(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let toRemove = self?.experiences.filter({ ProfileService.shared.reported.contains($0.id) }).map({ $0.id }),
                !toRemove.isEmpty
                else { return }
            
            toRemove.forEach { self?.removeExperience(id: $0) }
        }
    }
}

extension ExploreListAdapter: UIScrollViewDelegate {
    
    /*
    private var currentCell: ExploreCollectionViewCell? {
        guard let collectionView = collectionView else { return nil }
        
        let idx = Int(round((collectionView.contentOffset.x  + collectionView.contentInset.left) / cellSize.width))
        guard idx >= 0 && idx < filteredExperiences.count else { return nil }
        return collectionView.cellForItem(at: IndexPath(item: 0, section: idx)) as? ExploreCollectionViewCell
    }
    */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrolled?()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        panEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        panEnabled = true
        // currentCell?.shownOnTop()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            panEnabled = true
        }
    }
}


extension ExploreListAdapter: ExploreCollectionLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, transitionForItemAt indexPath: IndexPath) -> ExploreCollectionViewLayout.TransitionState {
        
        if loading {
            return .firstLoad
        }
        return transitionState
    }
}
