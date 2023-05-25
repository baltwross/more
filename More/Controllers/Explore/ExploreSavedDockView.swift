//
//  ExploreSavedDockView.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ExploreSavedDockView: LoadableView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    static let cellIdentifier = "ExploreSavedDockCollectionViewCell"
    
    @IBOutlet private weak var saveLabelContainer: UIView!
    @IBOutlet private weak var saveLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // to remove ---
    @IBOutlet private weak var fourth: UIView!
    @IBOutlet private weak var third: UIView!
    @IBOutlet private weak var second: UIView!
    @IBOutlet private weak var signalBar: SignalTopBar!

    private var signalBackground: UIColor!
    
    private var views: [UIView] {
        return [signalBar, second, third, fourth]
    }
    // ---
    
    private var saveBackground: UIColor!
    private var stack: [SignalViewModel] = []
    
    
    override func setupNib() {
        super.setupNib()
        
        saveBackground = saveLabelContainer.backgroundColor ?? .clear
        signalBackground = signalBar.backgroundColor ?? .clear
        
        setup()
    }
    
    private func setup() {
        saveLabelContainer.isHidden = false
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        collectionView.register(UINib(nibName: "ExploreSavedDockCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ExploreSavedDockView.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        for view in views {
            view.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in views {
            view.layoutIfNeeded()
            view.roundCorners(corners: [.topLeft, .topRight], radius: 8, background: signalBackground, shadow: .black)
        }
        saveLabelContainer.layoutIfNeeded()
        saveLabelContainer.roundCorners(corners: .allCorners, radius: saveLabel.frame.height * 0.5, background: saveBackground, shadow: .black)
    }
    
    func setup(for stack: [SignalViewModel]) {
        
        saveLabelContainer.isHidden = !stack.isEmpty
        self.stack = stack
        
        for (idx, view) in views.enumerated() {
            view.isHidden = !(idx < stack.count)
        }
        
        if let model = stack.last {
            signalBar.setup(for: model)
        }
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stack.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreSavedDockView.cellIdentifier, for: indexPath) as? ExploreSavedDockCollectionViewCell {
            cell.setup(for: stack[indexPath.item])
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - Delegate
    
    // TODO: - nothing ??
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath) {
        // TODO
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // TODO
    }
}


