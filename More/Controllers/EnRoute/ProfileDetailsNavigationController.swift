//
//  ProfileDetailsViewController.swift
//  More
//
//  Created by Luko Gjenero on 06/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileDetailsNavigationController: UIViewController {

    private var profileId: String? = nil
    
    var back: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNestedNavigation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setup(for model: UserViewModel) {
        profileId = model.id
        
        let vc = ProfileViewController()
        vc.backTap = { [weak self] in
            self?.back?()
        }
        vc.moreTap = { [weak self] in
            self?.report(model.user.short())
        }
        _ = vc.view
        
        vc.setup(for: model)
        navigation.setViewControllers([vc], animated: false)
        navigation.delegate = self
    }
    
    // MARK: - navigation controller
    
    private let navigation = UINavigationController()
    
    private func setupNestedNavigation() {
        navigation.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.willMove(toParent: self)
        navigation.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        navigation.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        navigation.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigation.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        navigation.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - overlay
    
   

}

extension ProfileDetailsNavigationController {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        /*
        if let vc = viewController as? ProfileViewController {
            
        }
        */
    }
}
