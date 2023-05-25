//
//  CreateSignalPhotoViewController.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Photos

class CreateSignalPhotoViewController: UIViewController {

    @IBOutlet private weak var selector: CreateSignalPhotoSelectorView!
    @IBOutlet private weak var selectorTop: NSLayoutConstraint!
    @IBOutlet private weak var done: BottomButton!
    
    // var back: (()->())?
    var selected: ((_ images: [UIImage]?, _ urls: [String]?, _ videos: [Data]?, _ previews: [UIImage?]?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selector.layer.cornerRadius = 12
        selector.enableShadow(color: .black)
        
        selector.providerSelected = { [weak self] type in
            UIResponder.resignAnyFirstResponder()
            
            if type == .search {
                self?.animateLayout(expanded: false, info: nil)
            } else if type == .camera {
                self?.animateLayout(expanded: false, info: nil)
            } else {
                self?.animateLayout(expanded: true, info: nil)
            }
        }
        
        selector.photoSelected = { [weak self] type in
            if type == .search {
                self?.done.isDisabled = (self?.selector.urls.count ?? 0) == 0
            } else if type == .camera {
                self?.selected?(self?.selector.images, nil, self?.selector.videos, self?.selector.previews)
            } else {
                self?.done.isDisabled = (self?.selector.assets.count ?? 0) == 0
            }
        }
        
        selector.done = { [weak self] in
            if self?.selector.provider == .search {
                self?.selected?(nil, self?.selector.urls, nil, nil)
            } else if self?.selector.provider == .album {
                self?.doneForAssets()
            }
        }
        
        done.isDisabled = true
        
        done.tap = { [weak self] in
            if self?.selector.provider == .search {
                self?.selected?(nil, self?.selector.urls, nil, nil)
            } else if self?.selector.provider == .album {
                self?.doneForAssets()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupLayout(expanded: false)
    }
    
    func setup(for model: CreateExperienceViewModel) {
        selector.setup(for: model)
    }
    
    // MARK: - iCloud
    
    private func doneForAssets() {
        if !selector.assets.isEmpty {
            let imageManager = PHCachingImageManager()
            loadAssets(manager: imageManager, assets: selector.assets, imageBuffer: []) { [weak self] images in
                self?.selected?(images, nil, nil, nil)
            }
        }
    }
    
    private func loadAssets(
        manager: PHCachingImageManager,
        assets: [PHAsset],
        imageBuffer: [UIImage],
        complete: ((_ images: [UIImage])->())?) {
        
        loadPhoto(manager: manager, assets: assets, imageBuffer: imageBuffer, complete: complete)
    }
    
    private func loadPhoto(
        manager: PHCachingImageManager,
        assets: [PHAsset],
        imageBuffer: [UIImage],
        complete: ((_ images: [UIImage])->())?) {
        
        guard let asset = assets.first else {
            DispatchQueue.main.async { [weak self] in
                self?.hideLoading()
            }
            complete?(imageBuffer)
            return
        }
        
        let restOfAssets = Array(assets.suffix(from: 1))
        var mutableBuffer = imageBuffer
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        let size = CGSize(width: 2048, height: 2048)
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { [weak self] image, info in
            if let image = image,
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, !isDegraded {
                mutableBuffer.append(image)
                self?.loadAssets(manager: manager, assets: restOfAssets, imageBuffer: mutableBuffer, complete: complete)
            } else {
                if let isIniCloud = info?[PHImageResultIsInCloudKey] as? Bool, isIniCloud {
                    self?.showLoading()
                }
            }
        })
    }
    
    // MARK: - UI
    
    func setupLayout(expanded: Bool) {
        selectorTop.constant = expanded ? 20 : 300
    }

    @objc private func keyboardUp(_ notification: Notification) {
        animateLayout(expanded: true, info: notification.userInfo)
    }
    
    @objc private func keyboardDown(_ notification: Notification) {
        // animateLayout(expanded: false, info: notification.userInfo)
    }

    private func animateLayout(expanded: Bool, info: [AnyHashable: Any]?) {
        
        var curve: UIView.AnimationOptions = .curveEaseInOut
        var duration: TimeInterval = 0.3

        if let userInfo = info,
            let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {

            curve = UIView.AnimationOptions(rawValue: animationCurve.uintValue)
            duration = animationDuration.doubleValue
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: curve,
            animations: { [weak self] in
                self?.setupLayout(expanded: expanded)
                self?.view.layoutIfNeeded()
            },
            completion: nil)
    }
    
}
