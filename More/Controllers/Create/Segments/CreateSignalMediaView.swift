//
//  CreateSignalMediaView.swift
//  More
//
//  Created by Luko Gjenero on 06/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let plusCell = "PlusCell"
private let imageCell = "ImageCell"



@IBDesignable
class CreateSignalMediaView: LoadableView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var photos: [CreateExperienceViewModel.Photo] = []
    
    var addTap: (()->())?
    var photoTap: ((_ photo: CreateExperienceViewModel.Photo)->())?
    var rearranged: ((_ photos: [CreateExperienceViewModel.Photo])->())?
    
    override func setupNib() {
        super.setupNib()
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        collectionView.register(PlusCell.self, forCellWithReuseIdentifier: plusCell)
        collectionView.register(Cell.self, forCellWithReuseIdentifier: imageCell)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        initReordering()
    }
    
    func setup(for model: CreateExperienceViewModel) {
        photos = model.images
        collectionView.reloadData()
        
        collectionView.isHidden = photos.count == 0
        addButton.isHidden = photos.count > 0
    }
    
    // MARK: - button
    
    @IBAction private func addTouch(_ sender: Any) {
        addTap?()
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photos.count > 0 {
            return photos.count + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < photos.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCell, for: indexPath) as? Cell {
                let photo = photos[indexPath.item]
                if let video = photo.video {
                    cell.setup(for: video)
                } else if let image = photo.image {
                    cell.setup(for: image)
                } else if let url = photo.url {
                    cell.setup(for: url)
                }
                return cell
            }
        } else if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: plusCell, for: indexPath) as? PlusCell {
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < photos.count {
            photoTap?(photos[indexPath.item])
        } else {
            addTap?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item < photos.count {
            return CGSize(width: 80, height: 80)
        } else {
            return CGSize(width: 48, height: 80)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Cell {
            cell.start()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? Cell {
            cell.pause()
        }
    }
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        private let video: MoreVideoView = {
            let video = MoreVideoView(frame: .zero)
            video.translatesAutoresizingMaskIntoConstraints = false
            video.backgroundColor = .clear
            video.clipsToBounds = true
            video.contentMode = .scaleAspectFill
            return video
        }()
        
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
            
            contentView.addSubview(video)
            contentView.addSubview(image)
            video.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            video.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            video.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            video.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
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
                self.video.reset()
            }
        }
        
        func setup(for video: Data?) {
            if let video = video {
                self.video.setup(for: video)
                self.video.isSilent = true
                self.image.sd_cancelCurrentImageLoad_progressive()
                self.image.image = nil
            }
        }
        
        func pause() {
            video.pause()
        }
        
        func start() {
            if !self.video.isPlaying {
                self.video.play(loop: true)
            }
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            video.reset()
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
        return photos.count > 0 && indexPath.item < photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        if proposedIndexPath.item >= photos.count {
            return IndexPath(item: photos.count-1, section: 0)
        }
        return proposedIndexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let image = photos[sourceIndexPath.row]
        photos.remove(at: sourceIndexPath.row)
        photos.insert(image, at: destinationIndexPath.row)
        
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
            collectionView.updateInteractiveMovementTargetPosition(location)
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}
