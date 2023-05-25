//
//  EditProfileContentView.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EditProfileContentView: LoadableView {

    @IBOutlet private weak var photosView: EditProfilePhotosView!
    @IBOutlet private weak var quoteView: EditProfileQuoteView!
    @IBOutlet private weak var nameView: EditProfileItemView!
    @IBOutlet private weak var genderView: EditProfileItemView!
    @IBOutlet private weak var birthdayView: EditProfileItemView!
    @IBOutlet private weak var phoneView: EditProfileItemView!
    @IBOutlet private weak var emailView: EditProfileItemView!
    @IBOutlet private weak var momentView: EditProfileMomentView!
    
    var addPhoto:(()->())?
    var editPhoto:((_ url: Image)->())?
    var photosRearranged: ((_ urls: [Image])->())?
    
    var quoteTap: (()->())?
    var nameTap: (()->())?
    var genderTap: (()->())?
    var birthdayTap: (()->())?
    var phoneTap: (()->())?
    var emailTap: (()->())?
    var momentTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        photosView.addTap = { [weak self] in
            self?.addPhoto?()
        }
        photosView.editTap = { [weak self] (image) in
            self?.editPhoto?(image)
        }
        photosView.rearranged = { [weak self] (images) in
            self?.photosRearranged?(images)
        }
        
        quoteView.editTap = { [weak self] in
            self?.quoteTap?()
        }
        
        phoneView.disabled = true
        
        quoteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(quoteTouch)))
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nameTouch)))
        genderView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(genderTouch)))
        birthdayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(birthdayTouch)))
        phoneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(phoneTouch)))
        emailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailTouch)))
        momentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(momentTouch)))
    }
    
    @objc private func quoteTouch() {
        quoteTap?()
    }
    
    @objc private func nameTouch() {
        nameTap?()
    }
    
    @objc private func genderTouch() {
        genderTap?()
    }
    
    @objc private func birthdayTouch() {
        birthdayTap?()
    }
    
    @objc private func phoneTouch() {
        phoneTap?()
    }
    
    @objc private func emailTouch() {
        emailTap?()
    }
    
    @objc private func momentTouch() {
        momentTap?()
    }
    
    func setup(for profile: Profile) {
        photosView.setup(for: profile)
        quoteView.setup(quote: profile.quote ?? "", quoteAuthor: profile.quoteAuthor ?? "")
        nameView.setup(subtitle: profile.fullName())
        genderView.setup(subtitle: profile.gender?.capitalized ?? "")
        if let bday = profile.birthday {
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yyyy"
            birthdayView.setup(subtitle: df.string(from: bday))
        } else {
            birthdayView.setup(subtitle: "")
        }
        phoneView.setup(subtitle: profile.formattedPhoneNumber)
        emailView.setup(subtitle: profile.email ?? "")
        momentView.setup(subtitle: profile.memories ?? "")
    }

}
