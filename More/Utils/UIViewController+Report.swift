//
//  UIViewController+Report.swift
//  More
//
//  Created by Luko Gjenero on 27/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import MessageUI

extension UIViewController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - report signal
    
    func report(_ experience: Experience, complete: ((_ reported: Bool)->())? = nil) {
        let alert = UIAlertController(title: "Report issue", message: "Do you want to report content displayed in this experience?", preferredStyle: .actionSheet)
        
        let report = UIAlertAction(title: "Report", style: .destructive, handler: { [weak self] _ in
            self?.reportAction(experience, complete: complete)
        })
        
        alert.addAction(report)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func reportAction(_ experience: Experience, complete: ((_ reported: Bool)->())? = nil) {
        let alert = UIAlertController(title: "Report issue", message: "Please specify the issue with content displayed in this experience.", preferredStyle: .actionSheet)
        
        let inappropriateContent = UIAlertAction(title: "Inappropriate content", style: .destructive, handler: { [weak self] _ in
            self?.sendReport(experience, reason: "Inappropriate content")
            complete?(true)
        })
        
        let spam = UIAlertAction(title: "Spam", style: .default, handler: { [weak self] _ in
            self?.sendReport(experience, reason: "Spam")
            complete?(true)
        })
        
        let other = UIAlertAction(title: "Other", style: .default, handler: { [weak self] _ in
            self?.sendReport(experience, reason: "Other")
            complete?(true)
        })
        
        alert.addAction(inappropriateContent)
        alert.addAction(spam)
        alert.addAction(other)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func sendReport(_ experience: Experience, reason: String) {
        
        ProfileService.shared.reportExperience(withId: experience.id)
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let body = """
            I would like to report the following time:
            Time Id: \(experience.id)
            Creator: \(experience.creator.name) (\(experience.creator.id))
            Reason: \(reason)
            """
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Report issue")
        mail.setMessageBody(body, isHTML: false)
        mail.setToRecipients([Emails.support])
        present(mail, animated: true, completion: { })
    }
    
    // MARK: - report profile

    func report(_ user: ShortUser, complete: ((_ reported: Bool)->())? = nil) {
        let alert = UIAlertController(title: "Report issue", message: "Do you want to report content displayed in this profile?", preferredStyle: .actionSheet)
        
        let report = UIAlertAction(title: "Report", style: .destructive, handler: { [weak self] _ in
            self?.reportAction(user, complete: complete)
        })
        
        alert.addAction(report)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func reportAction(_ user: ShortUser, complete: ((_ reported: Bool)->())? = nil) {
        let alert = UIAlertController(title: "Report issue", message: "Please specify the issue with content displayed in this profile.", preferredStyle: .actionSheet)
        
        let inappropriateContent = UIAlertAction(title: "Inappropriate content", style: .destructive, handler: { [weak self] _ in
            self?.sendReport(user, reason: "Inappropriate content")
            complete?(true)
        })
        
        let spam = UIAlertAction(title: "Spam", style: .default, handler: { [weak self] _ in
            self?.sendReport(user, reason: "Spam")
            complete?(true)
        })
        
        let other = UIAlertAction(title: "Other", style: .default, handler: { [weak self] _ in
            self?.sendReport(user, reason: "Other")
            complete?(true)
        })
        
        alert.addAction(inappropriateContent)
        alert.addAction(spam)
        alert.addAction(other)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func sendReport(_ user: ShortUser, reason: String, complete: ((_ reported: Bool)->())? = nil) {
        
        ProfileService.shared.blockUser(withId: user.id)
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let body = """
        I would like to report the following profile:
        Profile Id: \(user.id)
        Name: \(user.name)
        Reason: \(reason)
        """
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Report issue")
        mail.setMessageBody(body, isHTML: false)
        mail.setToRecipients([Emails.support])
        present(mail, animated: true, completion: { })
    }
    
    
    
    // MARK: - report chat
    
    func report(_ chat: Chat, complete: ((_ reported: Bool)->())? = nil) {
        let alert = UIAlertController(title: "Report issue", message: "Do you want to report \(chat.other().name)?", preferredStyle: .actionSheet)
        
        let report = UIAlertAction(title: "Report", style: .destructive, handler: { [weak self] _ in
            self?.reportAction(chat, complete: complete)
        })
        
        alert.addAction(report)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func reportAction(_ chat: Chat, complete: ((_ reported: Bool)->())? = nil) {
        let alert = UIAlertController(title: "Report issue", message: "Please specify the issue with \(chat.other().name).", preferredStyle: .actionSheet)
        
        let inappropriateContent = UIAlertAction(title: "Inappropriate content", style: .destructive, handler: { [weak self] _ in
            self?.sendReport(chat, reason: "Inappropriate content")
            complete?(true)
        })
        
        let spam = UIAlertAction(title: "Spam", style: .default, handler: { [weak self] _ in
            self?.sendReport(chat, reason: "Spam")
            complete?(true)
        })
        
        let other = UIAlertAction(title: "Other", style: .default, handler: { [weak self] _ in
            self?.sendReport(chat, reason: "Other")
            complete?(true)
        })
        
        alert.addAction(inappropriateContent)
        alert.addAction(spam)
        alert.addAction(other)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func sendReport(_ chat: Chat, reason: String, complete: ((_ reported: Bool)->())? = nil) {
        
        ProfileService.shared.blockUser(withId: chat.other().id)
        
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let body = """
        I would like to report the following user:
        Profile Id: \(chat.other().id)
        Name: \(chat.other().name)
        Reason: \(reason)
        """
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("Report issue")
        mail.setMessageBody(body, isHTML: false)
        mail.setToRecipients([Emails.support])
        present(mail, animated: true, completion: { })
    }
    
}
