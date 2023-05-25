//
//  CreateSignalMoodBottomView.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CreateSignalMoodBottomView: LoadableView {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: MoodSelectionView!
    @IBOutlet weak var previewButton: UIButton!
    
    private var model: CreateExperienceViewModel?
    private var types: [SignalType] = SignalType.all
    // private var needToScrollToSelection = false
    
    var backTap: (()->())?
    var previewTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        enableShadow(color: .black)
        
        collectionView.canUnselect = false
        collectionView.centered = true
        collectionView.selectionNumber = 1
        
        collectionView.selectionChanged = { [weak self] (selection) in
            if let type = selection.first {
                self?.model?.type = type
            } else {
                self?.model?.type = nil
            }
            self?.updatePreviewButton(dark: self?.model?.type != nil)
        }
    }
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if needToScrollToSelection {
            // if collectionView.visibleCells.count > 0 {
                needToScrollToSelection = false
                if let type = model?.type, let idx = SignalType.all.firstIndex(of: type) {
                    
                    let x = CGFloat(min(SignalType.all.count - 2, max(1, idx))) * collectionView.itemSize.width
                    collectionView.contentOffset = CGPoint(x: x, y: 0)
                    
                    /*
                    collectionView.scrollToItem(at: IndexPath(item: SignalType.all.firstIndex(of: type)!, section: 0), at: .centeredHorizontally, animated: false)
                     */
                }
            // }
        }
    }
    */
    
    @IBAction private func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction private func previewTouch(_ sender: Any) {
        previewTap?()
    }

    private func updatePreviewButton(dark: Bool) {
        if dark {
            previewButton.isUserInteractionEnabled = true
            previewButton.backgroundColor = Colors.previewDarkBackground
            previewButton.setTitleColor(Colors.previewDarkText, for: .normal)
        } else {
            previewButton.isUserInteractionEnabled = false
            previewButton.backgroundColor = Colors.previewLightBackground
            previewButton.setTitleColor(Colors.previewLightText, for: .normal)
        }
    }
    
    func setup(for model: CreateExperienceViewModel) {
        self.model = model
        updatePreviewButton(dark: model.type != nil)
        if let type = model.type {
            collectionView.setSelection([type])
            collectionView.needToScrollToSelection = true
        } else {
            collectionView.setSelection([])
        }
    }
    
    func animateToSelection() {
        if let type = model?.type {
            collectionView.scrollToItem(at: IndexPath(item: SignalType.all.firstIndex(of: type)!, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}
