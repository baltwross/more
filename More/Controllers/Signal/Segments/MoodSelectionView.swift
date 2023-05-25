//
//  MoodSelectionView.swift
//  More
//
//  Created by Luko Gjenero on 21/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let moodCell = "MoodCell"
private let moodFilterCell = "MoodFilterCell"

@IBDesignable
class MoodSelectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var types: [SignalType] = SignalType.all
    var selected: [SignalType] = []
    
    enum Style {
        case normal
        case filter
    }
    
    var style: Style = .normal {
        didSet {
            collectionViewLayout.invalidateLayout()
            DispatchQueue.main.async { [weak self] in
                self?.reloadData()
            }
        }
    }
    
    var selectionNumber: Int = 0 {
        didSet {
            if selectionNumber > 0 && selected.count > selectionNumber {
                selected = Array(selected.prefix(selectionNumber))
            }
            reloadData()
        }
    }
    
    var canUnselect: Bool = true
    
    var centered: Bool = true {
        didSet {
            if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                layout.itemSize = CGSize(width: 1, height: 1)
            }
            setNeedsLayout()
        }
    }
    
    var selectionChanged: ((_ selecteTypes: [SignalType])->())?
    
    var needToScrollToSelection = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    private func setup() {
        
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        register(UINib(nibName: moodCell, bundle: nil), forCellWithReuseIdentifier: moodCell)
        register(UINib(nibName: moodFilterCell, bundle: nil), forCellWithReuseIdentifier: moodFilterCell)
        decelerationRate = UIScrollView.DecelerationRate.fast
        
        delegate = self
        dataSource = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let itemSize = self.itemSize
            if itemSize.width != layout.itemSize.width || itemSize.height != layout.itemSize.height {
                layout.itemSize = itemSize

                layout.invalidateLayout()
                
                DispatchQueue.main.async { [weak self] in
                    self?.reloadData()
                    
                    if self?.needToScrollToSelection == true {
                        self?.needToScrollToSelection = false
                        
                        if self?.selected.count == 1, let type = self?.selected.first {
                            self?.scrollToItem(
                                at: IndexPath(item: SignalType.all.firstIndex(of: type)!, section: 0),
                                at: layout.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically,
                                animated: false)
                        }
                    }
                }
                
            }
        }
    }
    
    var itemSize: CGSize {
        if style == .filter {
            return CGSize(width: 150, height: frame.height)
        }
        return CGSize(width: floor(frame.width / 3), height: frame.height)
    }
    
    func setSelection(_ selectedTypes: [SignalType]) {
        var newSelection = selectedTypes
        if selectionNumber > 0 && newSelection.count > selectionNumber {
            newSelection = Array(newSelection.prefix(selectionNumber))
        }
        selected = newSelection
        reloadData()
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = style == .normal ? moodCell : moodFilterCell
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MoodCell {
            let type = types[indexPath.item]
            cell.setup(for: type, selected: selected.contains(type))
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let type = types[indexPath.item]
        var unselectedType: SignalType = .adventurous
        
        var selectedCell: MoodCell? = nil
        var unselectedCell: MoodCell? = nil
        
        if selected.contains(type) {
            if canUnselect {
                selected.removeAll(where: { $0 == type })
                unselectedCell = collectionView.cellForItem(at: indexPath) as? MoodCell
                unselectedType = type
            } else {
                return
            }
        } else {
            selected.append(type)
            if selectionNumber > 0 && selected.count > selectionNumber {
                unselectedType = selected.first!
                let unselectedIndex = types.firstIndex(of: unselectedType)!
                unselectedCell = collectionView.cellForItem(at: IndexPath(item: unselectedIndex, section: 0)) as? MoodCell
                selected = Array(selected.suffix(from: 1))
            }
            selectedCell = collectionView.cellForItem(at: indexPath) as? MoodCell
        }
        
        animateCell(cell: selectedCell, type: type, selected: true)
        animateCell(cell: unselectedCell, type: unselectedType, selected: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.reloadData()
        }
        
        if selectedCell != nil {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        selectionChanged?(selected)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        if layout.scrollDirection == .horizontal, velocity.x != 0 {
            let itemWidth = itemSize.width + layout.minimumInteritemSpacing
            var index = round((targetContentOffset.pointee.x + contentInset.left) / itemWidth)
            index = max(0, min(CGFloat(types.count), index))
            targetContentOffset.pointee = CGPoint(x: index * itemWidth - contentInset.left, y: 0)
        }
        
        if layout.scrollDirection == .vertical, velocity.y != 0 {
            let itemHeight = itemSize.height + layout.minimumLineSpacing
            var index = round((targetContentOffset.pointee.y + contentInset.top) / itemHeight)
            index = max(0, min(CGFloat(types.count), index))
            targetContentOffset.pointee = CGPoint(x: 0, y: index * itemHeight - contentInset.top)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        if !decelerate {
            
            if layout.scrollDirection == .horizontal {
                let itemWidth = itemSize.width + layout.minimumInteritemSpacing
                var index = Int(round((contentOffset.x + contentInset.left) / itemWidth))
                index = max(0, min(types.count, index))
                scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
            
            if layout.scrollDirection == .vertical {
                let itemHeight = itemSize.height + layout.minimumLineSpacing
                var index = Int(round((contentOffset.y + contentInset.top) / itemHeight))
                index = max(0, min(types.count, index))
                scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    // cell animation
    
    private func animateCell(cell: MoodCell?, type: SignalType, selected: Bool) {
        guard let cell = cell else { return }
        
        UIView.transition(
            with: cell,
            duration: 0.2,
            options: UIView.AnimationOptions.transitionCrossDissolve,
            animations: {
                cell.setup(for: type, selected: selected)
            },
            completion: { _ in })
    }
}
