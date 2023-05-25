//
//  CreateSignalPhotosCell.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalPhotosCell: CreateSignalBaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    static let height: CGFloat = 120
    
    private static let plusCellIdentifier = "PlusCell"
    private static let cellIdentifier = "ImageCell"
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var photos: [CreateExperienceViewModel.Photo] = []
    
    var addTap: (()->())?
    var photoTap: ((_ image: CreateExperienceViewModel.Photo)->())?
    var rearranged: ((_ photos: [CreateExperienceViewModel.Photo])->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        collectionView.register(PlusCell.self, forCellWithReuseIdentifier: CreateSignalPhotosCell.plusCellIdentifier)
        collectionView.register(Cell.self, forCellWithReuseIdentifier: CreateSignalPhotosCell.cellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        initReordering()
    }
    
    // MARK: - base
    
    override class func size(for model: CreateExperienceViewModel, in size: CGSize, keyboardVisible: Bool) -> CGSize {
        return CGSize(width: size.width, height: CreateSignalPhotosCell.height)
    }
    
    override class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        return model.images.count > 0
    }
    
    override func setup(for model: CreateExperienceViewModel, keyboardVisible: Bool) {
        photos = model.images
        collectionView.reloadData()
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateSignalPhotosCell.plusCellIdentifier, for: indexPath) as? PlusCell {
                return cell
            }
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateSignalPhotosCell.cellIdentifier, for: indexPath) as? Cell {
            let photo = photos[indexPath.item - 1]
            if let image = photo.image {
                cell.setup(for: image)
            } else {
                cell.setup(for: photo.url)
            }
            
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            addTap?()
        } else {
            photoTap?(photos[indexPath.item - 1])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: 48, height: 94)
        }
        return CGSize(width: 94, height: 94)
    }
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        private let image: BorderedImageView = {
            let image = BorderedImageView(frame: .zero)
            image.translatesAutoresizingMaskIntoConstraints = false
            image.backgroundColor = .clear
            image.contentMode = .scaleAspectFill
            image.ringSize = 3
            return image
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(image)
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            image.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            contentView.layoutIfNeeded()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for image: UIImage?) {
            self.image.sd_cancelCurrentImageLoad_progressive()
            self.image.image = image
        }
        
        func setup(for url: String?) {
            if let url = url {
                self.image.sd_progressive_setImage(with: URL(string: url), placeholderImage: UIImage.signalCreateThumbPlaceholder())
            }
        }
        
    }
    
    private class PlusCell: UICollectionViewCell {
        
        private let image: UIImageView = {
            let image = UIImageView(frame: .zero)
            image.translatesAutoresizingMaskIntoConstraints = false
            image.backgroundColor = .clear
            image.contentMode = .center
            image.image = UIImage(named: "add_gray")
            return image
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(image)
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            image.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            contentView.layoutIfNeeded()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    // MARK: - reordering
    
    private var longPressGesture: UILongPressGestureRecognizer!
    
    private func initReordering() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        addGestureRecognizer(longPressGesture)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return photos.count > 0 &&  indexPath.item > 0 && indexPath.item <= photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        if proposedIndexPath.item > photos.count {
            return IndexPath(item: photos.count, section: 0)
        }
        if proposedIndexPath.item == 0 {
            return IndexPath(item: 1, section: 0)
        }
        return proposedIndexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let image = photos[sourceIndexPath.row - 1]
        photos.remove(at: sourceIndexPath.row - 1)
        photos.insert(image, at: destinationIndexPath.row - 1)
        
        rearranged?(photos)
    }

    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            var location = gesture.location(in: gesture.view!)
            location.x += collectionView.contentOffset.x
            collectionView.updateInteractiveMovementTargetPosition(location) // gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}
