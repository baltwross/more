//
//  CreateSignalPhotoSelectorCameraProvider.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import MobileCoreServices

class CreateSignalPhotoSelectorCameraProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    typealias BufferedData = (String, Int)
    var buffer: (String, Int)?
    var bufferDelay: TimeInterval {
        return 0.5
    }
    var bufferTimer: Timer?
    
    private weak var collectionView: UICollectionView? = nil
    
    var photosSelected: [UIImage] = []
    var selectedPhotos: ((_ photos: [UIImage])->())?
    
    var videosSelected: [Data] = []
    var selectedVideos: ((_ videos: [Data], _ previews: [UIImage?])->())?
    
    func setup(for collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        openCamera()
    }
    
    func reset() {
        self.collectionView?.dataSource = nil
        self.collectionView?.delegate = nil
        self.collectionView = nil
    }
    
    // MARK: - camera
    
    private func openCamera() {
        collectionView?.findViewController()?.openCamera(
            allowVideo: ConfigService.shared.experienceVideoEnabled,
            videoDuration: ConfigService.shared.experienceVideoDuration,
            videoQuality: ConfigService.shared.experienceVideoQuality,
            image: { [weak self] image in
                self?.photosSelected = [image]
                self?.selectedPhotos?([image])
            },
            video: { [weak self] data, preview in
                self?.videosSelected = [data]
                self?.selectedVideos?([data], [preview])
            })
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) { }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
}
