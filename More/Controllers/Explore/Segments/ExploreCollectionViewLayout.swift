//
//  ExploreCollectionViewLayout.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

protocol ExploreCollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, transitionForItemAt indexPath: IndexPath) -> ExploreCollectionViewLayout.TransitionState
}

class ExploreCollectionViewLayout: UICollectionViewFlowLayout {
    
    enum TransitionState {
        case firstLoad, add, remove, removeEnd, refresh
    }
    
    var flowLayoutDelegate: UICollectionViewDelegateFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewDelegateFlowLayout
    }
    
    var exploreCollectionLayoutDelegate: ExploreCollectionLayoutDelegate?
    
    private func updateAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        
        guard let collectionView = collectionView else { return }
    
        let center = collectionView.contentOffset.x + collectionView.contentInset.left + itemSize.width * 0.5
        let distance = -abs(center - attributes.frame.midX) / itemSize.width
        let scale = 0.85 + exp(distance) * 0.15
        let yOffset = (1 - scale) * itemSize.height * 0.5
        
        var transform = CATransform3DMakeTranslation(0, -yOffset, 0)
        transform = CATransform3DScale(transform, scale, scale, 1)
        
        attributes.zIndex = Int(scale * 10)
        attributes.transform3D = transform
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var updatedAttributes: [UICollectionViewLayoutAttributes] = []
        for itemAttributes in attributes {
            let copiedAttributes = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            updateAttributes(copiedAttributes)
            updatedAttributes.append(copiedAttributes)
        }
        return updatedAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView else { return nil }

        let copiedAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        var frame = CGRect(origin: .zero, size: itemSize)
        frame.origin.x = /* collectionView.contentInset.left + */ itemSize.width * CGFloat(indexPath.section)
        copiedAttributes.frame = frame
        updateAttributes(copiedAttributes)
        return copiedAttributes
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                           withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        var target = proposedContentOffset.x + collectionView.contentInset.left
        if abs(velocity.x) > 3 {
            target += velocity.x * itemSize.width
        } else if abs(velocity.x) > 0 {
            
            let offset = collectionView.contentOffset.x + collectionView.contentInset.left
            let index = offset / itemSize.width
            let remainder = index.truncatingRemainder(dividingBy: 1)
            
            if remainder < 0.2 || remainder > 0.8 {
                target = offset
            } else {
                let proposedOffset = proposedContentOffset.x + collectionView.contentInset.left
                let proposedIndex = proposedOffset / itemSize.width
                if proposedIndex - index >= 1 {
                    target += itemSize.width
                } else if proposedIndex - index <= -1 {
                    target -= itemSize.width
                }
            }
        }
        target = round(target / itemSize.width)
        target = max(0, min(CGFloat(collectionView.numberOfSections), target))
        target = target * itemSize.width - collectionView.contentInset.left
        return CGPoint(x: target, y: proposedContentOffset.y)
    }
    
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let itemAttributes = layoutAttributesForItem(at: itemIndexPath)
        itemAttributes?.alpha = 0
        return itemAttributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView,
            let transition = exploreCollectionLayoutDelegate?.collectionView(collectionView, layout: collectionView.collectionViewLayout, transitionForItemAt: itemIndexPath)
            else {
            return layoutAttributesForItem(at: IndexPath(item: 0, section: itemIndexPath.section + 1))
        }
        
        
        
        switch transition {
        case .firstLoad:
            let attrs = layoutAttributesForItem(at: itemIndexPath)
            attrs?.alpha = 0
            return attrs
        case .remove:
            return layoutAttributesForItem(at: IndexPath(item: 0, section: itemIndexPath.section + 1))
        case .removeEnd:
            
            let attrs = layoutAttributesForItem(at: itemIndexPath)
            
            return attrs
            
            // return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
            
            /*
            if let attrs = layoutAttributesForItem(at: itemIndexPath) {
                attrs.frame.origin.x -= itemSize.width
                updateAttributes(attrs)
                return attrs
            }
            return nil
            */
            
            // return layoutAttributesForItem(at: itemIndexPath)
            
            // return layoutAttributesForItem(at: IndexPath(item: 0, section: itemIndexPath.section - 1))
        case .add:
            return layoutAttributesForItem(at: IndexPath(item: 0, section: itemIndexPath.section + 1))
        default:
            let attrs = layoutAttributesForItem(at: itemIndexPath)
            attrs?.alpha = 0
            return attrs
        }
    }
}
