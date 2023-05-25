//
//  EnRouteV2ViewController+state.swift
//  More
//
//  Created by Luko Gjenero on 14/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class EnRouteV2ViewStateController {
    
    private var time: ExperienceTime?
    private var container: UIView
    private var containerHeight: NSLayoutConstraint
    private weak var root: UIViewController?
    private var isVisible: Bool = false
    
    init(container: UIView, height: NSLayoutConstraint, root: UIViewController) {
        
        self.container = container
        self.containerHeight = height
        self.root = root
        
        NotificationCenter.default.addObserver(self, selector: #selector(timeState(_:)), name: TimesService.Notifications.TimeStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(timeExpired(_:)), name: TimesService.Notifications.TimeExpired, object: nil)
    }
    
    func appeared() {
        isVisible = true
        updateStates()
    }
    
    func disappeared() {
        isVisible = false
    }
    
    func setup(for time: ExperienceTime) {
        self.time = time
        updateStates()
    }
    
    @objc private func timeState(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let time = notice.userInfo?["time"] as? ExperienceTime, time.id == self?.time?.id {
                self?.updateStates()
            }
        }
    }
    
    @objc private func timeExpired(_ notice: Notification) {
        DispatchQueue.main.async { [weak self] in
            if let timeId = notice.userInfo?["timeId"] as? String, timeId == self?.time?.id {
                self?.timeFinished()
            }
        }
    }
    
    private func updateStates() {
        guard let time = time else { return }
        guard isVisible else { return }
        
        if let updated = TimesService.shared.getActiveTime(), updated.id == time.id {
            let myState = updated.state()
            if updated.cancelled() {
                showCancelledView()
                return
            }
            
            switch myState {
            case .queryMet:
                showQueryMetView()
            case .queryArrived:
                showQueryArrivedView()
            default:
                clearUI()
            }
        }
    }
    
    private func timeFinished() {
        clearUI()
        
        let alert = UIAlertController(title: "Time over", message: "Looks like you met. Great! Have a nice time!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Will do", style: .default, handler: { [weak self] _ in
            self?.root?.dismiss(animated: true, completion: nil)
        })
        alert.addAction(ok)
        root?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UI
    
    private func addToContainer(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        view.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
    }
    
    private func showCancelledView() {
        clearUI()
        
        let alert = UIAlertController(title: "Time cancelled", message: "Looks like this time you won't meet up.", preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let time = self?.time else { return }
            TimesService.shared.closeTime(experienceId: time.post.experience.id, timeId: time.id)
            self?.root?.dismiss(animated: true, completion: nil)
        })
        alert.addAction(ok)
        root?.present(alert, animated: true, completion: nil)
    }
    
    private func showQueryMetView() {
        var metBar: EnRouteMeetupBar?
        if let bar = container.subviews.first as? EnRouteMeetupBar {
            metBar = bar
        } else {
            clearUI()
            let bar = EnRouteMeetupBar()
            
            addToContainer(bar)
            metBar = bar
        }
        metBar?.type = .met
        metBar?.setup(text: "Did you find each other?")
        metBar?.tap = { [weak self] in
            self?.askMet()
        }
        containerHeight.constant = 80
    }
    
    private func showQueryArrivedView() {
        var metBar: EnRouteMeetupBar?
        if let bar = container.subviews.first as? EnRouteMeetupBar {
            metBar = bar
        } else {
            clearUI()
            let bar = EnRouteMeetupBar()
            
            addToContainer(bar)
            metBar = bar
        }
        metBar?.type = .arrive
        metBar?.setup(text: "Did you arrive?")
        metBar?.tap = { [weak self] in
            self?.askArrived()
        }
        containerHeight.constant = 80
    }
    
    private func clearUI() {
        container.subviews.forEach { $0.removeFromSuperview() }
        containerHeight.constant = 0
    }
    
    private func askMet() {
        let alert = UIAlertController(title: "Met?", message: "Please confirm you met.", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes we met", style: .default, handler: { [weak self] _ in
            guard let time = self?.time else { return }
            TimesService.shared.metTime(experienceId: time.post.experience.id, timeId: time.id)
        })
        let no = UIAlertAction(title: "Not yet", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        root?.present(alert, animated: true, completion: nil)
    }
    
    private func askArrived() {
        let alert = UIAlertController(title: "Arrived?", message: "Please confirm you arrived at the meet point.", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes I arrived", style: .default, handler: { [weak self] _ in
            guard let time = self?.time else { return }
            TimesService.shared.arrivedTime(experienceId: time.post.experience.id, timeId: time.id)
        })
        let no = UIAlertAction(title: "Not yet", style: .cancel, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        root?.present(alert, animated: true, completion: nil)
    }
    
}
