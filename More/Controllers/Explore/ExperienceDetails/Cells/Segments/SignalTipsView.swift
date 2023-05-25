//
//  SignalTipsView.swift
//  More
//
//  Created by Luko Gjenero on 29/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class SignalTipsView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private static let cellIdentifier = "TipCell"
    
    private var tips: [ExperienceTip] = []
    
    var upvoteTip: ((_ tip: ExperienceTip)->())?
    var downvoteTip: ((_ tip: ExperienceTip)->())?
    
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
        register(Cell.self, forCellWithReuseIdentifier: SignalTipsView.cellIdentifier)
        dataSource = self
        delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let itemSize = self.itemSize
            if !itemSize.equalTo(layout.itemSize) {
                layout.itemSize = itemSize
                layout.invalidateLayout()
                reloadData()
            }
        }
    }
    
    private var itemSize: CGSize {
        return CGSize(
            width: bounds.width - contentInset.left - contentInset.right,
            height: bounds.height)
    }
    
    func setup(for experience: Experience) {
        tips = experience.tips ?? []
        reload()
    }
    
    private func reload() {
        isScrollEnabled = tips.count > 0
        reloadData()
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SignalTipsView.cellIdentifier, for: indexPath) as? Cell {
            let tip = tips[indexPath.item]
            if indexPath.item < tips.count {
                cell.setup(for: tip)
            } else {
                cell.setupForEmpty()
            }
            cell.upVote = { [weak self] in
                self?.upvoteTip?(tip)
            }
            cell.downVote = { [weak self] in
                self?.downvoteTip?(tip)
            }
            
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // nothing
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var spacing: CGFloat = 15
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            spacing = layout.minimumInteritemSpacing
        }

        var index = round((targetContentOffset.pointee.x + contentInset.left) / (itemSize.width + spacing))
        index = max(0, min(CGFloat(tips.count), index))
        targetContentOffset.pointee = CGPoint(x: index * (itemSize.width + spacing) - contentInset.left, y: 0)        
    }
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        private let tipView: SignalTipView = {
            let tipView = SignalTipView()
            tipView.translatesAutoresizingMaskIntoConstraints = false
            tipView.clipsToBounds = true
            tipView.backgroundColor = .clear
            tipView.layer.cornerRadius = 15
            tipView.layer.masksToBounds = true
            return tipView
        }()
        
        var upVote: (()->())?
        var downVote: (()->())?
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(tipView)

            tipView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            tipView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            tipView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            tipView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            
            contentView.setNeedsLayout()
            
            tipView.upVote = { [weak self] in
                self?.upVote?()
            }
            tipView.downVote = { [weak self] in
                self?.downVote?()
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            enableShadow(color: .black, path: UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for tip: ExperienceTip) {
            tipView.setup(for: tip)
        }
        
        func setupForEmpty() {
            // nothing
        }
    }
    
}
