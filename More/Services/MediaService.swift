//
//  MediaService.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import FirebaseStorage

class MediaService {
    
    struct Notifications {
        static let MediaLoaded = NSNotification.Name(rawValue: "com.more.media.loaded")
    }
    
    struct Buckets {
        static let Signals = "signals"
        static let Users = "users"
        static let Chats = "chats"
    }
    
    class func newSignalImageFilename() -> String {
        return "\(ProfileService.shared.profile?.id ?? "xxx")-\(Date().timeIntervalSince1970)"
    }
    
    class func newSignalVideoFilename() -> String {
        return "\(ProfileService.shared.profile?.id ?? "xxx")-\(Date().timeIntervalSince1970)"
    }
    
    class func newSignalVideoPreviewFilename() -> String {
        return "\(ProfileService.shared.profile?.id ?? "xxx")-\(Date().timeIntervalSince1970)-preview"
    }
    
    class func newChatImageFilename() -> String {
        return "\(ProfileService.shared.profile?.id ?? "xxx")-\(Date().timeIntervalSince1970)"
    }
    
    class func newChatVideoFilename() -> String {
        return "\(ProfileService.shared.profile?.id ?? "xxx")-\(Date().timeIntervalSince1970)"
    }
    
    class func newChatVideoPreviewFilename() -> String {
        return "\(ProfileService.shared.profile?.id ?? "xxx")-\(Date().timeIntervalSince1970)-preview"
    }
    
    class func path(bucket: String, filename: String) -> String {
        return "\(bucket)/\(filename)"
    }
    
    static let shared = MediaService()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        toForeground()
    }
    
    @objc private func toForeground() {
        // TODO
    }
    
    @objc private func toBackground() {
        // TODO
    }
    
    private lazy var ref : StorageReference = {
        return Storage.storage().reference()
    }()
    
    func uploadImage(to bucket: String, name: String, image: UIImage, compression: CGFloat = 1, completion: ((_ success: Bool, _ url: String?, _ path: String?, _ errorMessage: String?)->())?) {
        
        guard let data = UIImageProgressiveJPEGRepresentation(image, compression) else {
            completion?(false, nil, nil, "Data error")
            return
        }
        
        let imageRef = ref.child(MediaService.path(bucket: bucket, filename: name))
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(data, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                completion?(false, nil, nil, error?.localizedDescription)
                return
            }
            
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion?(false, nil, nil, error?.localizedDescription)
                    return
                }
                
                completion?(true, downloadURL.absoluteString, imageRef.fullPath, nil)
            }
        }
    }
    
    func uploadVideo(to bucket: String, name: String, data: Data, completion: ((_ success: Bool, _ url: String?, _ path: String?, _ errorMessage: String?)->())?) {
        
        
        let videoRef = ref.child(MediaService.path(bucket: bucket, filename: name))
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        videoRef.putData(data, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                completion?(false, nil, nil, error?.localizedDescription)
                return
            }
            
            videoRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    completion?(false, nil, nil, error?.localizedDescription)
                    return
                }
                
                completion?(true, downloadURL.absoluteString, videoRef.fullPath, nil)
            }
        }
    }
    
}
