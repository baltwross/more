//
//  EnRouteCancelViewController.swift
//  More
//
//  Created by Luko Gjenero on 09/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import MessageUI

class EnRouteCancelViewController: UIViewController {
    
    private var time: ExperienceTime?
    
    var back: (()->())?
    var cancel: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .popover
        
        showOptionsView()
    }
    
    func setup(for time: ExperienceTime) {
        self.time = time
    }
    
    private func addPanel(_ panel: UIView) {
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        
        panel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        panel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        panel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func animate(from: UIView, to: UIView, subType: CATransitionSubtype) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = subType
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(transition, forKey: kCATransition)
        from.removeFromSuperview()
        addPanel(to)
    }
    
    private func showOptionsView() {
        stopTrackingKeyboard()
        let options = CancelOptionsView()
        
        if let previous = view.subviews.first {
            animate(from: previous, to: options, subType: .fromLeft)
        } else {
            addPanel(options)
        }
        
        options.backTap = { [weak self] in
            self?.back?()
        }
        options.cancelTap = { [weak self] in
            self?.showCancelMessage()
        }
        options.issueTap = { [weak self] in
            self?.cancel(.issue)
        }
        options.unsafeTap = { [weak self] in
            self?.cancel(.unsafe)
        }
    }
    
    private func showCancelMessage() {
        guard let time = time else { return }
        let message = EnRouteCancelMesasgeView()
        
        if let previous = view.subviews.first {
            animate(from: previous, to: message, subType: .fromRight)
        } else {
            addPanel(message)
        }
        
        message.setup(for: time)
        message.back = { [weak self] in
            self?.showOptionsView()
        }
        message.profile = { [weak self] in
            guard let time = self?.time else { return }
            self?.presentUser(time.post.creator.id)
        }
        message.done = { [weak self] text in
            self?.cancel(.cancel, text: text)
        }
        
        bottomContraint = message.bottomPadding
        trackKeyboardAndPushUp()
    }
    
    private func cancel(_ type: EnRouteCancelledView.Option, text: String? = nil) {
        guard let time = time else { return }
        
        TimesService.shared.cancelTime(experienceId: time.post.experience.id, timeId: time.id, flagged: type == .unsafe, message: text)
        
        showCancelled(type)
    }
    
    private func showCancelled(_ type: EnRouteCancelledView.Option) {
        stopTrackingKeyboard()
        let cancelled = EnRouteCancelledView()
        
        if let previous = view.subviews.first {
            animate(from: previous, to: cancelled, subType: .fromRight)
        } else {
            addPanel(cancelled)
        }
        
        cancelled.option = type
        cancelled.tap = { [weak self] in
            switch type {
            case .cancel:
                self?.cancel?()
            case .issue:
                self?.reportIssue()
            case .unsafe:
                self?.dial911()
            }
        }
    }
    
    private func reportIssue() {
        guard let time = time else { return }
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let body = """
        I would like to report issue with the following time:
        Time Id: \(time.id)
        Creator: \(time.post.creator.name) (\(time.post.creator.id))
        
        Reason:
        """
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Report issue")
        mail.setMessageBody(body, isHTML: false)
        mail.setToRecipients([Emails.support])
        present(mail, animated: true, completion: { })
    }
    
    private func dial911() {
        if let url = URL(string: "tel://911"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { [weak self] (_) in
                self?.cancel?()
            }
        } else {
            cancel?()
        }
    }
    
    override func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: { [weak self] in
            self?.cancel?()
        })
    }
}
