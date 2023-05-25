//
//  LoginInviteExcellentViewController.swift
//  More
//
//  Created by Igor Ostriz on 18/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Lottie
import UIKit

class LoginInviteExcellentViewController: BaseLoginViewController {
    
    @IBOutlet private weak var nextButton: FancyNextButton!
    @IBOutlet private weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadLottie()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let location = LocationService.shared.currentLocation {
            ProfileService.shared.updateLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            nextButton.enableWithAnimation(true, false)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: LocationService.Notifications.LocationUpdate, object: nil)
            nextButton.enableWithAnimation(false, true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func locationUpdated() {
        if let location = LocationService.shared.currentLocation {
            ProfileService.shared.updateLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            nextButton.enableWithAnimation(true, false)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @IBAction func onNext(_ sender: FancyNextButton) {
        if PushNotificationService.shared.permissionsRequested {
            nextView?()
        } else {
            PushNotificationService.shared.requestPersmissions { [weak self] in
                DispatchQueue.main.async {
                    self?.nextView?()
                }
            }
        }
    }
    
    func loadLottie() {
        if let path = Bundle.main.path(forResource: "rambo-happy", ofType: "json", inDirectory: "Animations/rambo-happy") {
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
