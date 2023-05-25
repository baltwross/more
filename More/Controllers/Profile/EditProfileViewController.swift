//
//  EditProfileViewController.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var content: EditProfileContentView!
    
    var doneTap: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        
        content.addPhoto = { [weak self] in
            self?.addPhoto()
        }
        
        content.editPhoto = { [weak self] (image) in
            self?.editPhoto(image)
        }
        
        content.photosRearranged = { [weak self] (images) in
            self?.photosRearranged(images)
        }
        
        content.nameTap = { [weak self] in
            self?.editNameAndEmail()
        }
        
        content.emailTap = { [weak self] in
            self?.editNameAndEmail()
        }
        
        content.quoteTap = { [weak self] in
            self?.editQuote()
        }
        
        content.birthdayTap = { [weak self] in
            self?.editBirthday()
        }
        
        content.genderTap = { [weak self] in
            self?.editGender()
        }
        
        content.momentTap = { [weak self] in
            self?.editMemories()
        }
    }
    
    private func setupTabBar() {
        hidesBottomBarWhenPushed = true
    }
    
    private func update( ){
        if let profile = ProfileService.shared.profile {
            content.setup(for: profile)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }

    @IBAction func doneTouch(_ sender: Any) {
        doneTap?()
    }
    
    // MARK: - photo actions
    
    private func addPhoto() {
        replacingPhoto = nil
        openAlbum(image: { [weak self] (image) in
            self?.uploadImage(image)
        }, video: nil)
    }
    
    private func editPhoto(_ image: Image) {
        let alert = UIAlertController(title: "", message: "Do you want to replace or remove this photo?", preferredStyle: .actionSheet)
        
        let replace = UIAlertAction(title: "Replace", style: .default, handler: { [weak self] _ in
            self?.replacePhoto(image)
        })
        
        let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
            self?.removePhoto(image)
        })
        
        alert.addAction(replace)
        alert.addAction(remove)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func photosRearranged(_ images: [Image]) {
        ProfileService.shared.updateImages(images)
        update()
    }
    
    private var replacingPhoto: Image? = nil
    
    private func replacePhoto(_ image: Image) {
        replacingPhoto = image
        openAlbum(image: { [weak self] (image) in
            self?.uploadImage(image)
        }, video: nil)
    }
    
    private func removePhoto(_ image: Image) {
        var images = ProfileService.shared.profile?.images ?? []
        images.removeAll(where: { $0.url == image.url })
        ProfileService.shared.updateImages(images)
        update()
    }
    
    private func uploadImage(_ image: UIImage) {
        showLoading()
        
        let name = "\(ProfileService.shared.profile?.id ?? "---").\(Date().timeIntervalSince1970)"
        MediaService.shared.uploadImage(to: "users", name: name, image: image) { [weak self] (success, url, path, errorMsg) in
            
            self?.hideLoading()
            
            if let url = url, let path = path {
                var images = ProfileService.shared.profile?.images ?? []
                let image = Image(id: "\(abs(url.hashValue))", url: url, path: path, order: images.count)
                if let replacingPhoto = self?.replacingPhoto {
                    if let idx = images.firstIndex(where: { $0.url == replacingPhoto.url }) {
                        images.remove(at: idx)
                        images.insert(image, at: idx)
                    } else {
                        images.append(image)
                    }
                } else {
                    images.append(image)
                }
                ProfileService.shared.updateImages(images)
                self?.update()
            }
        }
    }
    
    // MARK: - editing
    
    private func editNameAndEmail() {
        let vc = EditProfileInfoViewController()
        _ = vc.view
        if let profile = ProfileService.shared.profile {
            vc.setup(for: profile)
        }
        vc.closeTap = { [weak self] (first, last, email) in
            if let profile = ProfileService.shared.profile {
                ProfileService.shared.updateInfo(
                    firstName: first ?? profile.firstName ?? "",
                    lastName: last ?? profile.lastName ?? "",
                    email: email ?? profile.email ?? "")
            }
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editQuote() {
        let vc = EditProfileQuoteViewController()
        _ = vc.view
        if let profile = ProfileService.shared.profile {
            vc.setup(for: profile)
        }
        vc.closeTap = { [weak self] (quote, author) in
            if let quote = quote {
                ProfileService.shared.updateQuote(quote: quote, author: author ?? "")
            }
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editBirthday() {
        let vc = EditProfileBirthdayViewController()
        _ = vc.view
        if let profile = ProfileService.shared.profile {
            vc.setup(for: profile)
        }
        vc.closeTap = { [weak self] (birthday) in
            ProfileService.shared.updateBirthday(birthday)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editGender() {
        let vc = EditProfileGenderViewController()
        _ = vc.view
        if let profile = ProfileService.shared.profile {
            vc.setup(for: profile)
        }
        vc.closeTap = { [weak self] (gender) in
            ProfileService.shared.updateGender(gender)
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editMemories() {
        let vc = EditProfileMomentViewController()
        _ = vc.view
        if let profile = ProfileService.shared.profile {
            vc.setup(for: profile)
        }
        vc.closeTap = { [weak self] (moment) in
            if let profile = ProfileService.shared.profile {
                ProfileService.shared.updateMemories(moment ?? profile.memories ?? "")
            }
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}
