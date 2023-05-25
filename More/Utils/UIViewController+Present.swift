//
//  UIViewController+Present.swift
//  More
//
//  Created by Luko Gjenero on 10/01/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentUser(_ userId: String) {
        
        self.showLoading()
        ProfileService.shared.loadProfile(withId: userId) { [weak self] (profile, _) in
            self?.hideLoading()
            if let profile = profile {
                
                let vc = ProfileDetailsNavigationController()
                _ = vc.view
                vc.back = { [weak self] in
                    self?.dismiss(animated: true, completion: nil)
                }
                vc.setup(for: UserViewModel(profile: profile))
                self?.present(vc, animated: true, completion: nil)
                
                /*
                let model = UserViewModel(profile: profile)
                let vc = ProfileViewController()
                _ = vc.view
                vc.bottomPadding = 0
                vc.backTap = {
                    self?.dismiss(animated: true, completion: nil)
                }
                vc.moreTap = {
                    self?.report(model) { (reported) in
                        if reported {
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                vc.setup(for: model)
                
                let nc = UINavigationController(rootViewController: vc)
                nc.setNavigationBarHidden(true, animated: false)
                self?.present(nc, animated: true, completion: nil)
                */
            }
        }
    }
    
    func presentSignal(_ signalId: String) {
        // TODO: - remove
    }
    
    func presentExperience(_ experienceId: String) {
        // TODO
        
        showLoading()
        ExperienceService.shared.loadExperience(experienceId: experienceId) { [weak self] (experience, _) in
            self?.hideLoading()
            
            guard let experience = experience else { return }
            
            let vc = ExperienceDetailsNavigationController()
            vc.back = {
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
            vc.deleted = {
                self?.dismiss(animated: true, completion: nil)
            }
            
            _ = vc.view
            
            vc.setupForPast(experience)
            
            let nc = SignalDetailsNavigation(rootViewController: vc)
            nc.setNavigationBarHidden(true, animated: false)
            nc.modalPresentationStyle = .popover
            self?.present(nc, animated: true, completion: nil)
            nc.enableSwipeToPop()
        }
    }
    
    func presentGroup(_ users: [ShortUser]) {

        let overlay = ChatGroupManagementView()
        overlay.setup(for: users)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        
        overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlay.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.layoutIfNeeded()
        
        overlay.setupForEnterFromAbove()
        overlay.enterFromAbove()
        
        overlay.close = { [weak overlay] in
            overlay?.exitFromAbove({
                overlay?.removeFromSuperview()
            })
        }
        
        overlay.add = { [weak overlay] in
            // TODO
        }
        
        overlay.selectedUser = { [weak self] user in
            self?.presentUser(user.id)
        }
    }

}
