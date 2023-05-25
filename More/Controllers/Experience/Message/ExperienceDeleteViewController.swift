//
//  ExperienceDeleteViewController.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ExperienceDeleteViewController: ExperienceRequestViewController {

    @IBOutlet private weak var deleteContainer: UIView!
    @IBOutlet private weak var delete: ExperienceStartBar!
    
    var deleted: (()->())?
    var activated: ((_ post: ExperiencePost)->())?
    
    private var experience: Experience?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        deleteContainer.layer.cornerRadius = 12
        deleteContainer.enableShadow(color: .black)
        delete.startTap = { [weak self] in
            self?.activateExperience()
        }
    }

    override func setup(for experience: Experience) {
        self.experience = experience
        delete.setup(for: experience)
    }
    
    private func activateExperience() {
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
        guard let experience = experience else { return }
        guard let user = ProfileService.shared.profile?.user else { return }
        
        let post = ExperiencePost.create(experience: experience, user: user, isSilent: silent)
            .postWithLocation(LocationService.shared.currentLocation?.geoPoint())
        
        showLoading()
        ExperienceService.shared.createExperiencePost(for: experience, post: post, complete: { [weak self] (postId, error) in
            self?.hideLoading()

            if let postId = postId {
                self?.activated?(post.postWithId(postId))
            }
        })
    }
}
