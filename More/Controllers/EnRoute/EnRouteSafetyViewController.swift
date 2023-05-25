//
//  EnRouteSafetyViewController.swift
//  More
//
//  Created by Luko Gjenero on 29/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import MessageUI

class EnRouteSafetyViewController: UIViewController {

    @IBOutlet private weak var backgroundButton: UIButton!
    @IBOutlet private weak var container: UIView!
    
    private var currentView: UIView? = nil
    private var time: ExperienceTime? = nil
    
    var close: ((_ cancelled: Bool)->())? = nil
    var presenter: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupForSelection()
        setupForEnterFromBelow()
        trackKeyboardAndPushUp()
    }
    
    private var isFirst = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        enterFromBelow()
    }
    
    func setup(for time: ExperienceTime) {
        self.time = time
    }
    
    @IBAction private func backgroundTouch(_ sender: Any) {
        if currentView is EnRouteSafetyCancelledView {
            closeView(true)
        } else {
            closeView(false)
        }
    }
    
    private func closeView(_ cancelled: Bool) {
        exitFromBelow { [weak self] in
            self?.close?(cancelled)
        }
    }
    
    private func addView(_ view: UIView) {
        currentView?.removeFromSuperview()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(view)
        
        let bottom = view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        bottom.isActive = true
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        // view.layoutIfNeeded()
        bottomContraint = bottom
        currentView = view
    }
    
    private func move(to: UIView, fromLeft: Bool) {
        if currentView == nil {
            addView(to)
        } else {
            let transition = CATransition()
            transition.type = CATransitionType.push
            transition.subtype = fromLeft ? CATransitionSubtype.fromLeft : CATransitionSubtype.fromRight
            addView(to)
            container.layer.add(transition, forKey: "push")
        }
    }
    
    private func setupForSelection() {
        let view = EnRouteSafetySelectionView()
        view.cancelTap = { [weak self] in
            self?.setupForCancel()
        }
        view.issueTap = { [weak self] in
            self?.setupForIssue()
        }
        view.unsafeTap = { [weak self] in
            self?.setupForUnsafe()
        }
        move(to: view, fromLeft: true)
    }
    
    private func setupForCancel() {
        let view = EnRouteCancelMessageView()
        view.backTap = { [weak self] in
            self?.setupForSelection()
        }
        view.send = { [weak self] (message) in
            self?.sendMessageAndCancel(message)
        }
        if let time = time {
            view.setup(for: time)
        }
        move(to: view, fromLeft: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak view] in
            view?.showKeyboard()
        }
    }
    
    private func setupForIssue() {
        guard let time = time else { return }
        TimesService.shared.cancelTime(experienceId: time.post.experience.id, timeId: time.id)
        setupForCancelled(.issue)
    }
    
    private func setupForUnsafe() {
        guard let time = time else { return }
        TimesService.shared.cancelTime(experienceId: time.post.experience.id, timeId: time.id, flagged: true)
        setupForCancelled(.unsafe)
    }
    
    private func setupForCancelled(_ type: EnRouteSafetyCancelledView.OptionType) {
        let view = EnRouteSafetyCancelledView()
        view.type = type
        view.buttonTap = { [weak self] in
            switch type {
            case .cancel:
                self?.closeView(true)
            case .issue:
                self?.reportIssue()
            case .unsafe:
                self?.dial911()
            }
        }
        move(to: view, fromLeft: false)
    }

    private func sendMessageAndCancel(_ text: String) {
        guard let time = time else { return }
        TimesService.shared.cancelTime(experienceId: time.post.experience.id, timeId: time.id, message: text)
        setupForCancelled(.cancel)
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
        presenter?.present(mail, animated: true, completion: { })
    }
    
    private func dial911() {
        if let url = URL(string: "tel://911"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { [weak self] (_) in
                self?.closeView(true)
            }
        } else {
            closeView(true)
        }
    }
    
    override func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        presenter?.dismiss(animated: true, completion: { [weak self] in
            self?.closeView(true)
        })
    }
}
