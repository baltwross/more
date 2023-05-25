//
//  ExploreTopBar.swift
//  More
//
//  Created by Luko Gjenero on 14/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import IGListKit

class ExploreTopBar: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private static let cellIdentifier = "ExploreTopBarCollectionViewCell"
    
    private var experiences: [Experience] = []
    
    var isEmpty: Bool {
        return experiences.count == 0
    }
    
    var profileTap: ((_ experience: Experience) -> ())?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        register(UINib(nibName: "ExploreTopBarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ExploreTopBar.cellIdentifier)
        delegate = self
        dataSource = self
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
    }
    
    private var cellSize: CGSize {
        return CGSize(width: frame.width , height: 60)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layoutIfNeeded()
            let itemSize = frame.size
            if itemSize.width != layout.itemSize.width || itemSize.height != itemSize.height {
                layout.itemSize = itemSize
                collectionViewLayout.invalidateLayout()
                reloadData()
            }
        }
    }
    
    func setup(for experiences: [Experience]) {
        updateData(experiences)
    }
    
    private func updateData(_ experiences: [Experience]) {
        
        /*
        if self.models.count > 0 {
            if models.count > self.models.count {
                var insertions: [Int] = []
                for (idx, model) in models.enumerated() {
                    if !self.models.contains(model) {
                        insertions.append(idx)
                    }
                }
                if self.models.count + insertions.count == models.count {
                    self.models = models
                    insertCells(at: insertions)
                    return
                }
                
            } else if models.count < self.models.count {
                var deletions: [Int] = []
                for (idx, model) in self.models.enumerated() {
                    if !models.contains(model) {
                        deletions.append(idx)
                    }
                }
                if self.models.count == models.count + deletions.count {
                    self.models = models
                    deleteCells(at: deletions)
                    return
                }
            }
        }
        */
        
        self.experiences = experiences
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
        if isEmpty {
            return 1
        }
        return experiences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreTopBar.cellIdentifier, for: indexPath) as? ExploreTopBarCollectionViewCell {
            if isEmpty {
                cell.setupEmpty()
                cell.profileTap = nil
            } else {
                let experience = experiences[indexPath.item]
                cell.setup(for: experience)
                cell.profileTap = { [weak self] in
                    self?.profileTap?(experience)
                }
            }
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath) {
        // TODO
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO
    }

}
