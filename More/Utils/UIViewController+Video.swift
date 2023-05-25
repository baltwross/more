//
//  UIViewController+Video.swift
//  More
//
//  Created by Luko Gjenero on 10/01/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import AVKit
import Photos
import PhotosUI
import CoreServices

extension UIViewController {
    
    func playVideo(url urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        present(vc, animated: true, completion: nil)
    }

}

// MARK: - photo / video selector

private var kUIViewControllerImagePickerCallback : UInt8 = 0
private var kUIViewControllerVideoPickerCallback : UInt8 = 0

typealias ImagePickerCallback = ((_ image: UIImage)->())
typealias VideoPickerCallback = ((_ data: Data, _ preview: UIImage?)->())

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var imagePickerCallback: ImagePickerCallback? {
        get {
            return objc_getAssociatedObject(self, &kUIViewControllerImagePickerCallback) as? ImagePickerCallback
        }
        set {
            objc_setAssociatedObject(self, &kUIViewControllerImagePickerCallback, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var videoPickerCallback: VideoPickerCallback? {
        get {
            return objc_getAssociatedObject(self, &kUIViewControllerVideoPickerCallback) as? VideoPickerCallback
        }
        set {
            objc_setAssociatedObject(self, &kUIViewControllerVideoPickerCallback, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func openAlbum(allowVideo: Bool = false, videoDuration: TimeInterval = 0, videoQuality: String = "low", image: ImagePickerCallback?, video: VideoPickerCallback?) {
        openPicker(.photoLibrary, allowVideo: allowVideo, videoDuration: videoDuration, videoQuality: videoQuality, image: image, video: video)
    }
    
    func openCamera(allowVideo: Bool = false, videoDuration: TimeInterval = 0, videoQuality: String = "low", image: ImagePickerCallback?, video: VideoPickerCallback?) {
        openPicker(.camera, allowVideo: allowVideo, videoDuration: videoDuration, videoQuality: videoQuality, image: image, video: video)
    }
    
    private func openPicker(_ type: UIImagePickerController.SourceType, allowVideo: Bool = false, videoDuration: TimeInterval = 0, videoQuality: String = "low", image: ImagePickerCallback?, video: VideoPickerCallback?) {
        if UIImagePickerController.isSourceTypeAvailable(type) {
            
            imagePickerCallback = image
            videoPickerCallback = video
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = type
            imagePicker.allowsEditing = true
            if allowVideo {
                imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String, kUTTypeImage as String]
                
                imagePicker.videoMaximumDuration = videoDuration
                switch videoQuality {
                case "640":
                    imagePicker.videoQuality = .type640x480
                case "960":
                    imagePicker.videoQuality = .typeIFrame960x540
                case "1280":
                    imagePicker.videoQuality = .typeIFrame1280x720
                case "medium":
                    imagePicker.videoQuality = .typeMedium
                case "high":
                    imagePicker.videoQuality = .typeHigh
                default:
                    imagePicker.videoQuality = .typeLow
                }
            }
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            if asset.mediaType == .video {
                guard let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                    let data = try? Data(contentsOf: url)
                    else { loadVideo(asset); return }
                loadVideo(url, data)
            } else if asset.mediaType == .image {
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    imagePickerCallback?(image)
                } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    imagePickerCallback?(image)
                } else {
                    loadPhoto(asset)
                }
            }
        } else if let type = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if type == kUTTypeMovie as String {
                guard let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                    let data = try? Data(contentsOf: url)
                    else { return }
                loadVideo(url, data)
            } else if type == kUTTypeImage as String {
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    imagePickerCallback?(image)
                } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    imagePickerCallback?(image)
                } else if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) {
                    imagePickerCallback?(image)
                }
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    // MARK: - iCloud
    
    private func loadPhoto(_ asset : PHAsset) {

        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        let size = CGSize(width: 2048, height: 2048)
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { [weak self] image, info in
            if let image = image,
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, !isDegraded {
                self?.imagePickerCallback?(image)
            } else {
                if let isIniCloud = info?[PHImageResultIsInCloudKey] as? Bool, isIniCloud {
                    self?.showLoading()
                }
            }
        })
    }
        
    private func loadVideo(_ url: URL, _ data: Data) {
        let avAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: avAsset)
        imageGenerator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 0.0, preferredTimescale: 60)
        var actualTime = CMTimeMake(value: 0, timescale: 0)
        
        var preview: UIImage? = nil
        if let cgPreview = try? (imageGenerator.copyCGImage(at: timestamp, actualTime: &actualTime)) {
            preview = UIImage(cgImage: cgPreview)
        }
        videoPickerCallback?(data, preview)
    }
    
    private func loadVideo(_ asset : PHAsset) {

        let imageManager = PHCachingImageManager()
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        switch ConfigService.shared.chatVideoQuality {
        case "640":
            options.deliveryMode =  .mediumQualityFormat
        case "960":
            options.deliveryMode =  .mediumQualityFormat
        case "1280":
            options.deliveryMode =  .mediumQualityFormat
        case "medium":
            options.deliveryMode =  .mediumQualityFormat
        case "high":
            options.deliveryMode =  .highQualityFormat
        default:
            options.deliveryMode =  .fastFormat
        }
        options.deliveryMode =  .fastFormat
        imageManager.requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, _, info) in
            
            if let avAsset = avAsset,
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, !isDegraded {
                
                guard let avAssetURL = avAsset as? AVURLAsset,
                    let data = try? Data(contentsOf: avAssetURL.url)
                    else { self?.hideLoading(); return }
                self?.loadVideo(avAssetURL.url, data)
            } else {
                if let isIniCloud = info?[PHImageResultIsInCloudKey] as? Bool, isIniCloud {
                    self?.showLoading()
                }
            }
        }
    }
    
}

// MARK: - video editor

private var kUIViewControllerVideoEditCallback : UInt8 = 0

typealias VideoEditCallback = ((_ data: Data)->())

extension UIViewController: UIVideoEditorControllerDelegate {
    
    private var videoEditCallback: VideoEditCallback? {
        get {
            return objc_getAssociatedObject(self, &kUIViewControllerVideoEditCallback) as? VideoEditCallback
        }
        set {
            objc_setAssociatedObject(self, &kUIViewControllerVideoEditCallback, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func editVideo(path: String, videoDuration: TimeInterval, videoQuality: String = "low", video: VideoEditCallback?) {
        guard UIVideoEditorController.canEditVideo(atPath: path) else {
            return
        }
        
        videoEditCallback = video
        
        let vc = UIVideoEditorController()
        vc.delegate = self
        vc.videoPath = path
        vc.videoMaximumDuration = videoDuration
        switch videoQuality {
        case "640":
            vc.videoQuality = .type640x480
        case "960":
            vc.videoQuality = .typeIFrame960x540
        case "1280":
            vc.videoQuality = .typeIFrame1280x720
        case "medium":
            vc.videoQuality = .typeMedium
        case "high":
            vc.videoQuality = .typeHigh
        default:
            vc.videoQuality = .typeLow
        }
        present(vc, animated: true, completion: nil)
    }
    
    public func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        
        dismiss(animated: true, completion: nil)
        
        guard let url = URL(string: editedVideoPath),
            let data = try? Data(contentsOf: url)
            else { return }
        
        videoEditCallback?(data)
    }
    
    public func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        dismiss(animated: true, completion: nil)
    }
    
    public func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        dismiss(animated: true, completion: nil)
    }
    
}
