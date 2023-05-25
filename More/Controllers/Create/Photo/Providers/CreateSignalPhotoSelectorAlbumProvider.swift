//
//  CreateSignalPhotoSelectorAlbumProvider.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class CreateSignalPhotoSelectorAlbumProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var fetchResult: PHFetchResult<PHAsset>?
    var assetCollection: PHAssetCollection!
    var availableWidth: CGFloat = 0
    
    private let imageManager = PHCachingImageManager()
    private var previousPreheatRect = CGRect.zero
    
    private let cellIdentifier = "AlbumCell"
    
    private weak var collectionView: UICollectionView? = nil
    
    var assetsSelected: [PHAsset] = []
    var selectedAssets: ((_ asssets: [PHAsset], _ force: Bool)->())?
    
    var photosSelected: [UIImage] = []
    var selectedPhotos: ((_ photos: [UIImage])->())?
    
    var videosSelected: [Data] = []
    var selectedVideos: ((_ videos: [Data], _ previews: [UIImage?])->())?
    
    override init() {
        super.init()
        
        imageManager.allowsCachingHighQualityImages = false
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        resetCachedAssets()
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setup(for collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        collectionView.register(Cell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func reset() {
        resetCachedAssets()
        self.collectionView?.dataSource = nil
        self.collectionView?.delegate = nil
        self.collectionView = nil
    }
    
    // MARK: - album search
    
    func showRecent() {
        resetCachedAssets()
        let fetchRecentAlbum : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        var photoAlbum: PHAssetCollection? = nil
        fetchRecentAlbum.enumerateObjects { (collection, _, stop) in
            if collection.localizedTitle?.lowercased().hasPrefix("recent") == true {
                photoAlbum = collection
                stop.pointee = true
            }
        }
        if let photoAlbum = photoAlbum {
            let photosOptions = PHFetchOptions()
            photosOptions.predicate = NSPredicate(format: "mediaType == %i", PHAssetMediaType.image.rawValue)
            photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(in: photoAlbum, options: photosOptions)
            updateCachedAssets()
            collectionView?.reloadData()
        } else {
            let day30Ago = Date(timeIntervalSinceNow: -30 * 86400).startOfDay
            let photosOptions = PHFetchOptions()
            photosOptions.predicate = NSPredicate(format: "creationDate > %@ AND mediaType == %i", day30Ago as NSDate, PHAssetMediaType.image.rawValue)
            photosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: photosOptions)
            updateCachedAssets()
            collectionView?.reloadData()
        }
    }
    
    func showAll() {
        openAlbums()
    }
    
    private var imageSize: CGSize {
        var thumbnailSize: CGSize = CGSize(width: 100, height: 100)
        if let collectionView = collectionView {
            if let itemSize = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize {
                thumbnailSize = itemSize
            }
        }
        return CGSize(width: thumbnailSize.width * UIScreen.main.scale, height: thumbnailSize.height * UIScreen.main.scale)
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let fetchResult = fetchResult, indexPath.item < fetchResult.count,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? Cell {
            let asset = fetchResult.object(at: indexPath.item)
            
            cell.representedAssetIdentifier = asset.localIdentifier
            cell.selected(assetsSelected.firstIndex(of: asset))
            cell.setup(imageManager: imageManager, asset: asset, imageSize: imageSize)
            
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let fetchResult = fetchResult, indexPath.item < fetchResult.count {
            let photo = fetchResult[indexPath.item]
            if assetsSelected.contains(photo) {
                assetsSelected.removeAll(where: { $0 == photo })
            } else {
                assetsSelected.append(photo)
            }
            collectionView.reloadData()
        }
        selectedAssets?(assetsSelected, false)
    }
    
    // MARK: UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    /// - Tag: UpdateAssets
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard let fetchResult = fetchResult else { return }
        guard let collectionView = collectionView else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // The cell size
        let thumbnailSize: CGSize =  imageSize
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > collectionView.bounds.height / 3 && delta < collectionView.bounds.height else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    // MARK: - albums
    
    private func openAlbums() {
        collectionView?.findViewController()?.openAlbum(
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
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        var representedAssetIdentifier: String!
        private weak var imageManager: PHCachingImageManager?
        private var requestId: PHImageRequestID? = nil
        
        private let image: UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.clipsToBounds = true
            image.contentMode = .scaleAspectFill
            image.backgroundColor = UIColor(red: 241, green: 242, blue: 244)
            image.clipsToBounds = true
            return image
        }()
        
        private let badge: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "DIN-Bold", size: 13)
            label.textColor = .white
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.layer.cornerRadius = 10
            label.layer.masksToBounds = true
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(image)
            contentView.addSubview(badge)
            
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            image.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            
            badge.topAnchor.constraint(equalTo: image.topAnchor, constant: 10).isActive = true
            badge.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 10).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 20).isActive = true
            badge.widthAnchor.constraint(equalToConstant: 20).isActive = true
            contentView.setNeedsLayout()
        }
        
        override func prepareForReuse() {
            super .prepareForReuse()
            if let requestId = requestId {
                imageManager?.cancelImageRequest(requestId)
            }
            requestId = nil
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(imageManager: PHCachingImageManager, asset: PHAsset, imageSize: CGSize) {
            self.imageManager = imageManager
            self.requestId =
            imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, _ in
                if self?.representedAssetIdentifier == asset.localIdentifier {
                    self?.setup(for: image)
                }
            })
        }
        
        private func setup(for photo: UIImage?) {
            image.image = photo
        }
    
        func selected(_ selected: Int?) {
            if let selected = selected {
                badge.text = "\(selected + 1)"
                badge.backgroundColor = .brightSkyBlue
                badge.layer.borderColor = UIColor.clear.cgColor
                badge.layer.borderWidth = 0
            } else {
                badge.text = ""
                badge.backgroundColor = .clear
                badge.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
                badge.layer.borderWidth = 1
            }
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension CreateSignalPhotoSelectorAlbumProvider: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let fetchResult = fetchResult,
            let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            self.fetchResult = changes.fetchResultAfterChanges
            // If we have incremental changes, animate them in the collection view.
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                 to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                collectionView?.reloadData()
            }
            resetCachedAssets()
        }
    }
}
