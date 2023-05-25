//
//  LoginPhotoViewController.swift
//  More
//
//  Created by Luko Gjenero on 17/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class LoginPhotoViewController: BaseLoginViewController {
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var photo: AvatarImage!
    @IBOutlet private weak var photoButton: UIButton!
    @IBOutlet private weak var doneButton: BottomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController?.viewControllers.count == 0 {
            backButton.isHidden = true
        }
        
        photo.contentMode = .center
        
        doneButton.isDisabled = true
        doneButton.setTitle("ADD A PHOTO TO ENTER")
        doneButton.tap = { [weak self] in
            self?.doneTouch()
        }
    }
    
    @IBAction func backTouch(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func photoTouch(_ sender: Any) {
        openAlbum(image: { [weak self] (image) in
            self?.photo.image = image
            self?.photo.contentMode = .scaleAspectFill
            self?.check()
        }, video: nil)
    }
    
    private func doneTouch() {
        if let image = photo.image {
            
            showLoading()
            
            let name = "\(ProfileService.shared.profile?.id ?? "---").\(Date().timeIntervalSince1970)"
            MediaService.shared.uploadImage(to: "users", name: name, image: image) { [weak self] (success, url, path, errorMsg) in
                
                self?.hideLoading()
                
                if let url = url, let path = path {
                    var images = ProfileService.shared.profile?.images ?? []
                    let image = Image(id: "\(abs(url.hashValue))", url: url, path: path, order: images.count, isVideo: false)
                    images.append(image)
                    ProfileService.shared.updateImages(images)
                    DispatchQueue.main.async {
                        self?.hideLoading()
                        self?.nextView?()
                    }
                }
            }
        }
    }
    
    private func check() {
        if photo.image == nil {
            doneButton.setTitle("ADD A PHOTO TO ENTER")
        } else {
            doneButton.setTitle("ENTER")
        }
        doneButton.isDisabled = photo.image == nil
    }
}
