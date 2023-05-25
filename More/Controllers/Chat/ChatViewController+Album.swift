//
//  ChatViewController+Album.swift
//  More
//
//  Created by Luko Gjenero on 24/03/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import QuickLook

extension ChatViewController {

    func openAlbum() {
        openAlbum(
            allowVideo: ConfigService.shared.chatVideoEnabled,
            videoDuration: ConfigService.shared.chatVideoDuration,
            videoQuality: ConfigService.shared.chatVideoQuality,
            image: { [weak self] image in
                self?.sharePhoto(image)
            },
            video: { [weak self] data, preview in
                self?.shareVideo(data, preview: preview)
            })
    }
    
    // MARK: - upload
    
    private func sharePhoto(_ image: UIImage) {
        showLoading()
        
        let name = MediaService.newChatImageFilename()
        MediaService.shared.uploadImage(to: MediaService.Buckets.Chats, name: name, image: image) { [weak self] (success, url, path, errorMsg) in
            
            self?.hideLoading()
            
            if let url = url, let path = path {
                self?.sendMediaMessage(url: url, path: path, type: .photo)
            }
        }
    }
    
    private func shareVideo(_ data: Data, preview: UIImage? = nil) {
        showLoading()
        
        let name = MediaService.newChatVideoFilename()
        MediaService.shared.uploadVideo(to: MediaService.Buckets.Chats, name: name, data: data) { [weak self] (success, url, path, errorMsg) in
            
            if let url = url, let path = path {
                if let preview = preview {
                    let previewName = MediaService.newChatVideoPreviewFilename()
                    MediaService.shared.uploadImage(to: MediaService.Buckets.Chats, name: previewName, image: preview, compression: 0.5) { [weak self] (success, previewUrl, previewPath, errorMsg) in
                        
                        self?.hideLoading()
                        
                        self?.sendMediaMessage(url: url, path: path, type: .video, previewUrl: previewUrl, previewPath: previewPath)
                    }
                    return
                }
                self?.sendMediaMessage(url: url, path: path, type: .video)
            }
            self?.hideLoading()
        }
    }
    
    private func sendMediaMessage(url: String, path: String, type: MessageType, previewUrl: String? = nil, previewPath: String? = nil) {
        guard let profile = ProfileService.shared.profile else { return }
        
        let text = "\(profile.firstName ?? "") sent a \(type == .video ? "video" : "photo")"
        let additional =  Message.additionalMediaData(url: url, path: path, previewUrl: previewUrl, previewPath: previewPath)
        let data = Message.additionalData(from: additional)
        let messageId = "\(profile.id.hashValue)-\(Date().hashValue)"
        let message = Message(id: messageId, createdAt: Date(), sender: profile.shortUser, type: type, text: text, additionalData: data, deliveredAt: nil, readAt: nil)
        
        sendMessage(message)
    }
    
    // MARK: - error
    
    private func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        return
    }
    
}
