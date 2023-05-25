//
//  ExploreSectionController.swift
//  More
//
//  Created by Luko Gjenero on 31/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import IGListKit

private let cellIdentifier = "ExploreCollectionViewCell"

class ExploreSectionController: ListSectionController, ListDisplayDelegate {

    private let size: CGSize
    private var experience: Experience?
    private var loading: Bool = false
    
    var selected: ((_ experience: Experience)->())?
    var liked: ((_ experience: Experience)->())?
    var disliked: ((_ experience: Experience)->())?
    var creator: ((_ experience: Experience)->())?
    
    init(size: CGSize) {
        self.size = size
        super.init()
        self.displayDelegate = self
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return size
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        
        if let cell = collectionContext?.dequeueReusableCell(withNibName: "ExploreCollectionViewCell", bundle: nil, for: self, at: index) as? ExploreCollectionViewCell {
            if loading {
                cell.setupEmpty()
            }
            if let experience = experience {
                cell.setup(for: experience)
            }
            cell.likeTap = { [weak self, weak cell] liked in
                guard let experience = self?.experience else { return }
                var likes = experience.numOfLikes ?? 0
                likes += liked ? -1 : 1
                let updatedExperience = experience.experienceWithNumOfLikes(likes)
                cell?.setup(for: updatedExperience)
                cell?.setupLikes(!liked)
                if liked {
                    self?.disliked?(experience)
                } else {
                    self?.liked?(experience)
                }
            }
            cell.creatorTap = { [weak self] in
                guard let experience = self?.experience else { return }
                self?.creator?(experience)
            }
            return cell
        }
        
        return collectionContext!.dequeueReusableCell(of: UICollectionViewCell.self, withReuseIdentifier: "Dummy", for: self, at: index)
    }
    
    override func didUpdate(to object: Any) {
        experience = object as? Experience
        loading = object as? String == "loading"
    }
    
    override func didSelectItem(at index: Int) {
        guard let experience = experience else { return }
        selected?(experience)
    }
    
    // MARK: - manage signals
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        // nothing
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        // nothing
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        guard experience == nil else { return }
        if let cell = cell as? ExploreCollectionViewCell {
            cell.animate()
        }
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        // nothing
    }
    
    
}

