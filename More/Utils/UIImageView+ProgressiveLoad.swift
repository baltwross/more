//
//  UIImageView+ProgressiveLoad.swift
//  More
//
//  Created by Luko Gjenero on 16/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import CoreServices
import Nuke

private let pipeline = ImagePipeline {
    $0.isProgressiveDecodingEnabled = true
}

private var imageDownloadTaskKey: UInt8 = 0
private var imageDownloadIdKey: UInt8 = 0

extension UIImageView {
    
    /// download task
    var downloadTask: ImageTask? {
        get {
            return objc_getAssociatedObject(self, &imageDownloadTaskKey) as? ImageTask
        }
        set {
            objc_setAssociatedObject(self, &imageDownloadTaskKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// download id (url hash)
    var downloadId: Int {
        get {
            return objc_getAssociatedObject(self, &imageDownloadIdKey) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &imageDownloadIdKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    func sd_progressive_setImage(
        with url: URL?,
        placeholderImage: UIImage? = nil,
        options: SDWebImageOptions = [],
        progress: SDWebImageDownloaderProgressBlock? = nil,
        completed: SDExternalCompletionBlock? = nil) {
        
        /*
        var progressiveOptions = options
        progressiveOptions.insert(.progressiveDownload)
        
        // not using for now
        // progressiveOptions.insert(.progressiveLoad)
        // progressiveOptions.insert(.avoidDecodeImage)
        
        sd_setImage(
            with: url,
            placeholderImage: placeholderImage,
            options: progressiveOptions,
            progress: progress,
            completed: completed)
        */
        
        guard let url = url else { return }
        guard downloadId != url.hashValue else { return }
        
        downloadTask?.cancel()
        downloadTask = nil
        image = placeholderImage
        
        var task: ImageTask!
        task = pipeline.loadImage(
            with: url,
            queue: DispatchQueue.main,
            progress: { [weak self] (response, _, _) in
                guard self?.downloadTask == task else { return }
                if let image = response?.image {
                    if placeholderImage != nil && self?.image == placeholderImage {
                        self?.imageLoaded(image, animated: true)
                    } else {
                        self?.image = image
                    }
                }
            },
            completion: { [weak self] (result) in
                if self?.downloadTask == task {
                    self?.downloadTask = nil
                    switch result {
                    case .success(let response):
                        self?.imageLoaded(response.image, animated: placeholderImage != nil)
                    default: ()
                    }
                }
            })

        if options.contains(.highPriority) {
            task?.priority = .high
        }
        
        downloadTask = task
        downloadId = url.hashValue
    }
    
    private func imageLoaded(_ image: UIImage?, animated: Bool, contentMode: UIView.ContentMode? = nil) {
        
        if !animated {
            if let contentMode = contentMode {
                self.contentMode = contentMode
            }
            self.image = image
            return
        }
        
        UIView.transition(
            with: self,
            duration: 0.2,
            options: UIView.AnimationOptions.transitionCrossDissolve,
            animations: {
                if let contentMode = contentMode {
                    self.contentMode = contentMode
                }
                self.image = image
            },
            completion: nil)
    }
    
    func sd_cancelCurrentImageLoad_progressive() {
        downloadTask?.cancel()
        downloadTask = nil
        downloadId = 0
        image = nil
    }
        
}


//
// Taken from:
//

private var progressiveImageUrl: String? {
    let urls: [URL] = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    if let documentsUrl = urls.first {
        return documentsUrl.appendingPathComponent("progressive.jpeg").absoluteString
    }
    return nil
}

func UIImageProgressiveJPEGRepresentation(_ image: UIImage, _ compressionQuality: CGFloat) -> Data? {
    
    guard let cgImage = image.cgImage else { return nil }
    
    guard let stringUrl = progressiveImageUrl else { return nil }
    
    guard let url = CFURLCreateWithString(nil, stringUrl as CFString, nil) else { return nil }

    guard let destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG , 1, nil) else { return nil }
    
    let jfifProperties = [kCGImagePropertyJFIFIsProgressive: kCFBooleanTrue]
    
    let properties: [CFString : Any] = [kCGImageDestinationLossyCompressionQuality: compressionQuality,
                                        kCGImagePropertyJFIFDictionary: jfifProperties]
    
    CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
    CGImageDestinationFinalize(destination)
    
    guard let fileUrl = URL(string: stringUrl) else { return nil }
    
    return try? Data(contentsOf: fileUrl)
}

