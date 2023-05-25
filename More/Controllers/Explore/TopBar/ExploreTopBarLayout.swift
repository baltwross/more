//
//  ExploreTopBarLayout.swift
//  More
//
//  Created by Luko Gjenero on 14/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ExploreTopBarLayout: UICollectionViewFlowLayout {
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemAttributes = layoutAttributesForItem(at: itemIndexPath)
        itemAttributes?.alpha = 0
        return itemAttributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    
}
