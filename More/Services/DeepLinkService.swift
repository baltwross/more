//
//  DeepLinkService.swift
//  More
//
//  Created by Luko Gjenero on 06/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import DeepLinkKit

class DeepLinkService {
    
    static let shared = DeepLinkService()

    private let router: DPLDeepLinkRouter = DPLDeepLinkRouter()
    private var linkCache: URL?
    
    func setupRoutes() {
        
        router.register("experience") { [weak self] (link) in
            guard let link = link else { return }
            self?.processExperience(link)
        }
        
        router.register("time") { [weak self] (link) in
            guard let link = link else { return }
            self?.processTime(link)
        }
        
        router.register("profile") { [weak self] (link) in
            guard let link = link else { return }
            self?.processProfile(link)
        }
        
        router.register("requests") { [weak self] (link) in
            guard let link = link else { return }
            self?.processRequests(link)
        }
    }
    
    weak var rootView: MoreTabBarNestedNavigationController? {
        didSet {
            if rootView != nil, let url = getCache() {
                handle(url)
            }
        }
    }
    
    @discardableResult
    func handle(_ url: URL) -> Bool {
        let isHandled = router.handle(url, withCompletion: nil)
        return isHandled
    }
    
    func getCache() -> URL? {
        let url = linkCache
        linkCache = nil
        return url
    }
    
    private func processExperience(_ link: DPLDeepLink) {
        guard rootView != nil else {
            linkCache = link.url
            return
        }
        
        if let id = link.queryParameters["id"] as? String {
            ExperienceService.shared.loadExperience(experienceId: id) { [weak self] (experience, _) in
                if let experience = experience,
                    let root = self?.rootView,
                    let explore = root.viewControllers.first as? ExploreViewController {
                    root.popToRootViewController(animated: false)
                    explore.showExperience(experience: experience, check: true)
                }
            }
        }
    }
    
    private func processTime(_ link: DPLDeepLink) {
        if let id = link.queryParameters["id"] as? String {
            // TODO: - ??
        }
    }
    
    private func processProfile(_ link: DPLDeepLink) {
        guard let root = rootView else {
            linkCache = link.url
            return
        }
        
        if let id = link.queryParameters["id"] as? String {
            rootView?.presentUser(id)
        }
    }
    
    private func processRequests(_ link: DPLDeepLink) {
        // TODO: - move to requests
    }
    
}
