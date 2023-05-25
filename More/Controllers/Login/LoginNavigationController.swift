//
//  LoginNavigationController.swift
//  More
//
//  Created by Luko Gjenero on 29/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class BaseLoginViewController: UIViewController {
    
    static func create() -> BaseLoginViewController? {
        let storyboard = UIStoryboard.init(name: Storyboard.login, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? BaseLoginViewController
        return vc
    }
    
    var nextView: (()->())?
}

class LoginNavigationController: UINavigationController {

    private func nextViewController(for phase: ProfileService.ProfilePhase) -> BaseLoginViewController? {
        
        var vc: BaseLoginViewController?
        switch ProfileService.shared.profilePhase {
        case .phoneLogin:
            vc = LoginViewController.create()
        case .authentication:
            vc = LoginViewController.create()
        case .terms:
            vc = LoginInviteIntroViewController.create()
        case .requestLocation:
            vc = LoginRequestLocationViewController.create()
        case .locationNeeded:
            vc = LoginInviteDontWorryViewController.create()
        case .notAvailable:
            ()
        case .available:
            vc = LoginInviteExcellentViewController.create()
        case .info:
            vc = LoginInfoViewController.create()
        case .instagram:
            vc = LoginInstagramViewController.create()
        case .memories:
            vc = LoginMemoriesViewController.create()
        case .photo:
            vc = LoginPhotoViewController.create()
        case .invite:
            vc = LoginInviteToGetInViewController.create()
        case .ready:
            ()
        }
        
        vc?.nextView = { [weak self] in
            self?.moveToNextView()
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBarHidden(true, animated: false)
        
        if let vc = nextViewController(for: ProfileService.shared.profilePhase) {
            setViewControllers([vc], animated: false)
        }
    }
    
    private func moveToNextView() {
        if let vc = nextViewController(for: ProfileService.shared.profilePhase) {
            pushViewController(vc, animated: true)
        } else if ProfileService.shared.profilePhase == .ready {
            let nc = MoreTabBarNestedNavigationController()
            let vc = ExploreViewController()
            nc.viewControllers = [vc]
            AppDelegate.appDelegate()?.transitionRootViewController(viewController: nc, animated: true, completion: nil)
        }
    }

}
