//
//  CreateSignalPhotoSelectorView.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage
import Photos

class CreateSignalPhotoSelectorView: LoadableView {
    
    enum ProviderType {
        case search, album, camera
    }

    @IBOutlet private weak var tip: UIView!
    @IBOutlet private weak var searchButton: CreateSignalPhotoSourceButton!
    @IBOutlet private weak var uploadButton: CreateSignalPhotoSourceButton!
    @IBOutlet private weak var takeButton: CreateSignalPhotoSourceButton!
    @IBOutlet private weak var search: CreateSignalPlaceSearchView!
    @IBOutlet private weak var recentButton: UIButton!
    @IBOutlet private weak var allButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let searchProvider = CreateSignalPhotoSelectorSearchProvider()
    private let albumProvider = CreateSignalPhotoSelectorAlbumProvider()
    private let cameraProvider = CreateSignalPhotoSelectorCameraProvider()
    
    private var model: CreateExperienceViewModel?
    
    var urls: [String] = []
    var assets: [PHAsset] = []
    var images: [UIImage] = []
    var videos: [Data] = []
    var previews: [UIImage?] = []
    
    var photoSelected: ((_ type: ProviderType)->())?
    var providerSelected: ((_ type: ProviderType)->())?
    var done: (()->())?
    var provider: ProviderType = .search
    
    override func setupNib() {
        super.setupNib()
        
        searchButton.sourceType = .search
        searchButton.tap = { [weak self] in
            self?.setupSearch()
            self?.providerSelected?(.search)
            self?.provider = .search
        }
        
        search.placeholder = "Search for images"
        search.triggerChangeOnReturnOnly = true
        search.searchChanged = { [weak self] (text) in
            self?.searchProvider.searchUpdated(to: text ?? "", offset: 0)
            self?.search.closeKeyboard()
        }
        
        uploadButton.sourceType = .upload
        uploadButton.tap = { [weak self] in
            self?.setupAlbum()
            self?.providerSelected?(.album)
            self?.provider = .album
        }
        
        takeButton.sourceType = .take
        takeButton.tap = { [weak self] in
            self?.setupCamera()
            self?.providerSelected?(.camera)
            self?.provider = .camera
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        searchProvider.selectedPhotos = { [weak self] photos in
            self?.urls = photos.map { $0.url }
            self?.photoSelected?(.search)
            self?.search.closeKeyboard()
        }
        
        albumProvider.selectedAssets = { [weak self] photos, force in
            self?.assets = photos
            self?.photoSelected?(.album)
            if force {
                self?.done?()
            }
        }
        
        albumProvider.selectedPhotos = { [weak self] photos in
            self?.images = photos
            self?.photoSelected?(.camera)
        }
        
        albumProvider.selectedVideos = { [weak self] videos, previews in
            self?.videos = videos
            self?.previews = previews
            self?.photoSelected?(.camera)
        }
        
        cameraProvider.selectedPhotos = { [weak self] photos in
            self?.images = photos
            self?.photoSelected?(.camera)
        }
        
        cameraProvider.selectedVideos = { [weak self] videos, previews in
            self?.videos = videos
            self?.previews = previews
            self?.photoSelected?(.camera)
        }
        
        setupSearch()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let size = floor((frame.width - (3 * layout.minimumInteritemSpacing)) / 4)
            let cellSize = CGSize(width: size, height: size)
            if !layout.itemSize.equalTo(cellSize) {
                layout.itemSize = cellSize
                layout.invalidateLayout()
                collectionView.reloadData()
            }
        }
    }
    
    @IBAction private func recentTouch(_ sender: Any) {
        setupRecentAlbum()
    }
    
    @IBAction private func allTouch(_ sender: Any) {
        setupAllAlbum()
    }
    
    private func setupSearch() {
        albumProvider.reset()
        cameraProvider.reset()
        searchProvider.setup(for: collectionView)
        search.isHidden = false
        recentButton.isHidden = true
        allButton.isHidden = true
        
        searchButton.selected = true
        uploadButton.selected = false
        takeButton.selected = false
    }
    
    private func setupAlbum() {
        searchProvider.reset()
        cameraProvider.reset()
        albumProvider.setup(for: collectionView)
        albumProvider.showRecent()
        search.isHidden = true
        recentButton.isHidden = false
        allButton.isHidden = false
        recentButton.isSelected = true
        allButton.isSelected = false
        
        searchButton.selected = false
        uploadButton.selected = true
        takeButton.selected = false
    }
    
    private func setupRecentAlbum() {
        if allButton.isSelected {
            albumProvider.showRecent()
            recentButton.isSelected = true
            allButton.isSelected = false
        }
    }
    
    private func setupAllAlbum() {
        albumProvider.showAll()
    }
        
    private func setupCamera() {
        searchProvider.reset()
        albumProvider.reset()
        cameraProvider.setup(for: collectionView)
        search.isHidden = true
        recentButton.isHidden = true
        allButton.isHidden = true
        
        searchButton.selected = false
        uploadButton.selected = false
        takeButton.selected = true
    }
    
    func setup(for model: CreateExperienceViewModel) {
        self.model = model
        if searchProvider.searchString.isEmpty {
            searchProvider.searchUpdated(to: model.title, offset: 0)
        }
    }
}


