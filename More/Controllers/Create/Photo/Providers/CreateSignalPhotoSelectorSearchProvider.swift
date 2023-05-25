//
//  CreateSignalPhotoSelectorSearchProvider.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalPhotoSelectorSearchProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, BufferedRunInterface {
    
    typealias BufferedData = (String, Int)
    var buffer: (String, Int)?
    var bufferDelay: TimeInterval {
        return 0.5
    }
    var bufferTimer: Timer?
    
    private let cellIdentifier = "SearchCell"
    
    private(set) var searchString: String = ""
    private var photos: [ImageSearchService.ImageData] = []
    private var hasMorePhotos: Bool = true
    private weak var collectionView: UICollectionView? = nil
    
    var photosSelected: [ImageSearchService.ImageData] = []
    var selectedPhotos: ((_ photos: [ImageSearchService.ImageData])->())?
    
    func setup(for collectionView: UICollectionView) {
        searchString = ""
        photos = []
        hasMorePhotos = true
        
        self.collectionView = collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        collectionView.register(Cell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func reset() {
        self.collectionView?.dataSource = nil
        self.collectionView?.delegate = nil
        self.collectionView = nil
    }
    
    // MARK: - photo search
    
    func searchUpdated(to searchText: String, offset: Int) {
        bufferCall(with: (searchText, offset)) { [weak self] (serchText, offset) in
            self?.initiateSearch(searchText, offset: offset)
        }
    }
    
    private func initiateSearch(_ searchText: String, offset: Int) {
        
        guard searchText.count > 0 else {
            photos = []
            photosSelected = []
            collectionView?.reloadData()
            return
        }
        
        ImageSearchService.shared.searchImages(for: searchText, offset: offset) { [weak self] (results) in
            DispatchQueue.main.async {
                self?.searchString = searchText
                self?.hasMorePhotos = results.count > 0
                
                if offset > 0 {
                    self?.appendPhotos(results)
                } else {
                    self?.resetPhotos(results)
                }
            }
        }
    }
    
    private func appendPhotos(_ photos: [ImageSearchService.ImageData]) {
        var inserted: [IndexPath] = []
        for img in photos {
            if !self.photos.contains(img) {
                self.photos.append(img)
                inserted.append(IndexPath(item: self.photos.count-1, section: 0))
            }
        }
        collectionView?.insertItems(at: inserted)
    }
    
    private func resetPhotos(_ photos: [ImageSearchService.ImageData]) {
        photosSelected = []
        self.photos = []
        for img in photos {
            if !self.photos.contains(img) {
                self.photos.append(img)
            }
        }
        collectionView?.reloadData()
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < photos.count,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? Cell {
            let photo = photos[indexPath.item]
            cell.setup(for: photo, selected: photosSelected.firstIndex(of: photo))
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard photos.count > 0 else { return }
        
        if indexPath.item >= photos.count - 1 && hasMorePhotos {
            searchUpdated(to: searchString, offset: photos.count)
        }
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < photos.count {
            let photo = photos[indexPath.item]
            if photosSelected.contains(photo) {
                photosSelected.removeAll(where: { $0 == photo })
            } else {
                photosSelected.append(photo)
            }
            collectionView.reloadData()
        }
        selectedPhotos?(photosSelected)
    }
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        private let image: UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.clipsToBounds = true
            image.contentMode = .scaleAspectFill
            image.backgroundColor = UIColor(red: 241, green: 242, blue: 244)
            image.layer.masksToBounds = true
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
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for photo: ImageSearchService.ImageData, selected: Int?) {
            image.sd_progressive_setImage(with: URL(string: photo.url))
            
            if let selected = selected {
                badge.text = "\(selected+1)"
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
