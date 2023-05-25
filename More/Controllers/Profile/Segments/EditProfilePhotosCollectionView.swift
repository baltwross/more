//
//  EditProfilePhotosCollectionView.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class EditProfilePhotosCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private static let cellIdentifier = "ExploreTopBarCollectionViewCell"
    
    private var longPressGesture: UILongPressGestureRecognizer!
    private var photos: [Image] = []

    var addTap: (()->())?
    var editTap: ((_ url: Image)->())?
    var rearranged: ((_ urls: [Image])->())?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        register(UINib(nibName: "EditProfilePhotosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: EditProfilePhotosCollectionView.cellIdentifier)
        delegate = self
        dataSource = self
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
        }
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        addGestureRecognizer(longPressGesture)
    }
    
    private var cellSize: CGSize {
        return CGSize(width: floor((frame.width - 70) / 3), height: frame.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layoutIfNeeded()
            let itemSize = cellSize
            if itemSize.width != layout.itemSize.width || itemSize.height != layout.itemSize.height {
                layout.itemSize = itemSize
                collectionViewLayout.invalidateLayout()
                reloadData()
            }
        }
    }
    
    func setup(for models: [Image]) {
        updateData(models)
    }
    
    private func updateData(_ photos: [Image]) {
        self.photos = photos
        reloadData()
    }
    
    private func insertCells(at indicies: [Int]) {
        insertItems(at: indicies.map({ IndexPath(item: $0, section: 0) }))
    }
    
    private func deleteCells(at indicies: [Int]) {
        deleteItems(at: indicies.map({ IndexPath(item: $0, section: 0) }))
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(3, photos.count+1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditProfilePhotosCollectionView.cellIdentifier, for: indexPath) as? EditProfilePhotosCollectionViewCell {
            if indexPath.item < photos.count {
                let rowItem = photos[indexPath.item]
                cell.setup(for: rowItem.url)
                cell.editTap = { [weak self] in
                    self?.editTap?(rowItem)
                }
            } else {
                cell.editTap = nil
                cell.setupForAdd()
            }
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO
        if indexPath.item >= photos.count {
            addTap?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return photos.count > 0 && indexPath.item < photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        if proposedIndexPath.item >= photos.count {
            return IndexPath(item: photos.count - 1, section: 0)
        }
        return proposedIndexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let image = photos[sourceIndexPath.row]
        photos.remove(at: sourceIndexPath.row)
        photos.insert(image, at: destinationIndexPath.row)
        
        rearranged?(photos)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = indexPathForItem(at: gesture.location(in: self)) else {
                break
            }
            beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            endInteractiveMovement()
        default:
            cancelInteractiveMovement()
        }
    }
    
}
