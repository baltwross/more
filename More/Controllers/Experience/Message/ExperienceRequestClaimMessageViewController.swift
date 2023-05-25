//
//  ExperienceRequestClaimMessageViewController.swift
//  More
//
//  Created by Luko Gjenero on 03/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ExperienceRequestClaimMessageViewController: ExperienceRequestViewController {

    @IBOutlet private weak var confirmContainer: UIView!
    @IBOutlet private weak var confirm: ExperienceClaimBar!
    
    private var experience: Experience?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        confirmContainer.layer.cornerRadius = 12
        confirmContainer.enableShadow(color: .black)
        confirm.buttonTap = { [weak self] in
            self?.claim()
        }
    }
    
    private var isFirst: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        if TutorialService.shared.shouldShow(tutorial: .join) {
            let anchor = confirm.button.convert(CGPoint(x: confirm.button.bounds.midX, y: 0), to: view)
            TutorialService.shared.show(tutorial: .join, anchor: anchor, container: view, above: true)
        }
    }

    override func setup(for experience: Experience) {
        self.experience = experience
    }
    
    private func claim() {
        if ProfileService.shared.profile?.isAdmin == true {
            let alert = UIAlertController(title: "Silent", message: "Do you want this claim to NOT trigger notifications?", preferredStyle: .actionSheet)
            
            let silent = UIAlertAction(title: "Yes, make silent", style: .default, handler: { [weak self] _ in
                self?.executeClaim(true)
            })
            let notSilent = UIAlertAction(title: "No", style: .cancel, handler: { [weak self] _ in
                self?.executeClaim(false)
            })
            
            alert.addAction(silent)
            alert.addAction(notSilent)
            present(alert, animated: true, completion: nil)
            
        } else {
            executeClaim(false)
        }
    }
    
    private func executeClaim(_ silent: Bool) {
        guard let experience = experience, let me = ProfileService.shared.profile?.user else { return }
        
        let post = ExperiencePost.create(experience: experience, user: me, isSilent: silent)
            .postWithLocation(LocationService.shared.currentLocation?.geoPoint())
        ExperienceService.shared.createExperiencePost(for: experience, post: post) { [weak self] (experienceId, error) in
            if experienceId != nil {
                self?.done?()
            } else {
                if let nsError = error as NSError?,
                    nsError.domain == MoreError.domain,
                    nsError.code == MoreError.Codes.postAlreadyCreated.rawValue {
                    
                    // join existing post
                    ExperienceService.shared.loadExperience(experienceId: experience.id) { (experience, _) in
                        if let experience = experience,
                            let post = experience.activePost() {
                            
                            if post.creator.isMe() {
                                ExperienceTrackingService.shared.track(experienceId: experience.id, forceRefresh: true)
                                self?.done?()
                                return
                            }
                            
                            let request = ExperienceRequest(
                                id: "",
                                createdAt: Date(),
                                creator: me.short(),
                                post: post.short(),
                                message: nil)
                            ExperienceService.shared.createExperienceRequest(for: experience, post: post, request: request) { (requestId, errorMsg) in
                                if requestId != nil {
                                    self?.done?()
                                } else {
                                    self?.error?(errorMsg)
                                }
                            }
                            return
                        }
                        self?.error?("Unexpected error")
                    }
                } else {
                    self?.error?((error as NSError?)?.localizedDescription)
                }
            }
        }
    }

}
