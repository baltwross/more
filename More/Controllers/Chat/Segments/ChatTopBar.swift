//
//  ChatTopBar.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Firebase

@IBDesignable
class ChatTopBar: LoadableView {

    @IBOutlet private weak var countdown: CountdownLabel!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var eta: UILabel!
    @IBOutlet private weak var etaLabel: UILabel!
    
    var buttonTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        countdown.setDateFormat("m:ss")
    }
    
    func setup(signal: Signal, request: Request) {
        setup(for: signal)
        setEta(signal: signal, request: request)
        countdown.countdown(to: request.expiresAt)
    }
    
    private func setup(for signal: Signal) {
        
        NotificationCenter.default.removeObserver(self)
        
        countdown.countdown(to: signal.expiresAt)
        setEta(signal: signal)
        
        if !signal.isMine() {
            button.titleLabel?.font = UIFont(name: "Gotham-Bold", size: 10)
            button.setTitleColor(UIColor(red: 68, green: 74, blue: 80), for: .normal)
            button.setTitle("REMOVE REQUEST", for: .normal)
            button.setBackgroundImage(nil, for: .normal)
        }
    }
    
    private func setEta(signal: Signal, request: Request? = nil) {
        eta.isHidden = true
        etaLabel.isHidden = true
        eta.text = ""
        
        var signalLocation: GeoPoint? = signal.location
        if signal.isMine() {
            if let request = request {
                signalLocation = request.location
            } else {
                etaLabel.text = ""
                return
            }
        }
        
        etaLabel.text = "ETA"
        if let myLocation = LocationService.shared.currentLocation,
            let signalLocation = signalLocation {
            GeoService.shared.getDistanceAndETA(from: myLocation.coordinate, to: signalLocation.coordinates()) { [weak self] (_, time, _) in
                if let time = time {
                    let df = DateFormatter()
                    df.dateFormat = "h:mm a"
                    self?.eta.text = df.string(from: Date(timeIntervalSinceNow: time))
                    self?.etaLabel.text = "ETA"
                    self?.eta.isHidden = false
                    self?.etaLabel.isHidden = false
                }
            }
        }
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        buttonTap?()
    }
    
    @objc private func expirationChanged(_ notice: Notification) {
        if let signal = notice.userInfo?["signal"] as? Signal {
            countdown.countdown(to: signal.finalExpiration())
        }
    }

}
