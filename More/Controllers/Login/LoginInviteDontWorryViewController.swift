//
//  LoginInviteDontWorryViewController.swift
//  More
//
//  Created by Igor Ostriz on 17/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Lottie
import UIKit

class LoginInviteDontWorryViewController: BaseLoginViewController {
    
    @IBOutlet private weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        if LocationService.locationEnabled {
            nextView?()
        }
    }
    
    @IBAction func onFix(_ sender: UIButton) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    
    func loadLottie() {
        if let path = Bundle.main.path(forResource: "rambo-confused", ofType: "json", inDirectory: "Animations/rambo-confused") {
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
