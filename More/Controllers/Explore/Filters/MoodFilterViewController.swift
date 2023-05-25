//
//  MoodFilterViewController.swift
//  More
//
//  Created by Luko Gjenero on 21/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class MoodFilterViewController: UIViewController {

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var resetButton: UIButton!
    @IBOutlet private weak var strip: MoodFilterStrip!
    @IBOutlet private weak var collectionView: MoodSelectionView!
    @IBOutlet private weak var doneButton: UIButton!
    
    private var isFirst: Bool = true
    private var selection: [SignalType] = []
    
    var closeTap: (()->())?
    var doneTap: ((_ selectedTypes: [SignalType])->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        strip.contentInset = UIEdgeInsets(top: 16, left: 22, bottom: 0, right: 22)
        strip.removeType = { [weak self] (type) in
            self?.removeSelection(type)
        }
        
        collectionView.style = .filter
        collectionView.centered = false
        collectionView.selectionNumber = 0
        collectionView.canUnselect = true
        
        collectionView.selectionChanged = { [weak self] (selection) in
            self?.selection = selection
            self?.strip.setSelection(selection)
        }
        
        setupForEnterFromAbove()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirst else { return }
        isFirst = false
        
        enterFromAbove()
    }
    
    @IBAction func closeTouch(_ sender: Any) {
        exitFromAbove { [weak self] in
            self?.closeTap?()
        }
    }
    
    @IBAction func resetTouch(_ sender: Any) {
        selection = []
        collectionView.setSelection([])
        strip.setSelection([])
    }
    
    @IBAction func doneTouch(_ sender: Any) {
        exitFromAbove { [weak self] in
            guard let sself = self else { return }
            sself.doneTap?(sself.selection)
        }
    }
    
    func setSelection(_ selection: [SignalType]) {
        self.selection = selection
        collectionView.setSelection(selection)
        strip.setSelection(selection)
    }
    
    private func removeSelection(_ type: SignalType) {
        if let idx = selection.firstIndex(of: type) {
            selection.remove(at: idx)
            collectionView.setSelection(selection)
        }
    }
    
    
    
}
