//
//  LoginRequestLocationViewController.swift
//  More
//
//  Created by Igor Ostriz on 17/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Lottie
import UIKit

class LoginRequestLocationViewController: BaseLoginViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController?.viewControllers.count == 0 {
            backButton.isHidden = true
        }
        
//        if let referral = ProfileService.shared.profile?.referral, referral.count > 0 {
//            titleLabel.text = "Claim Invite"
//        } else {
//            titleLabel.text = "Request Invite"
//        }
        
        loadLottie()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationPremissionChanged), name: LocationService.Notifications.LocationPermissionChange, object: nil)
        locationPremissionChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func locationPremissionChanged() {
        if LocationService.locationEnabled || !LocationService.canRequestLocation {
            NotificationCenter.default.removeObserver(self)
            nextView?()
        }
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAllowLocation(_ sender: Any) {
        LocationService.shared.requestWhenInUse()
    }
    
    func loadLottie() {
        if let path = Bundle.main.path(forResource: "gemma", ofType: "json", inDirectory: "Animations/gemma") {
            let lottieView = LottieAnimationView(filePath: path)
            lottieView.contentMode = .scaleAspectFit
            lottieView.loopMode = .loop
            containerView.addSubview(lottieView)
            lottieView.translatesAutoresizingMaskIntoConstraints = false
            lottieView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            lottieView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
            lottieView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            lottieView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            
            lottieView.play()
        }
    }

}
