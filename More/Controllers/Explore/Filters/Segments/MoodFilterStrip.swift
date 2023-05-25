//
//  MoodFilterStrip.swift
//  More
//
//  Created by Luko Gjenero on 03/12/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let cell = "Cell"

class MoodFilterStrip: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private var types: [SignalType] = []
    
    var removeType: ((_ type: SignalType)->())?
    
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
        register(Cell.self, forCellWithReuseIdentifier: cell)
        decelerationRate = UIScrollView.DecelerationRate.fast
        
        delegate = self
        dataSource = self
    }
    
    
    func setSelection(_ selectedTypes: [SignalType]) {
        types = selectedTypes
        reloadData()
    }
    
    private func remove(_ type: SignalType) {
        if let idx = types.firstIndex(of: type) {
            types.remove(at: idx)
            removeType?(type)
            reloadData()
        }
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell, for: indexPath) as? Cell {
            let type = types[indexPath.item]
            cell.setup(for: type.rawValue.uppercased())
            cell.remove = { [weak self] in
                self?.remove(type)
            }
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // nothing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let type = types[indexPath.item]
        return size(for: type)
    }

    // MARK: - sizes
    
    private var sizes: [SignalType: CGSize] = [:]
    
    private func size(for type: SignalType) -> CGSize {
        
        if let size = sizes[type] {
            return size
        }
        
        let size = CGSize(width: Cell.size(for: type.rawValue.uppercased()), height: 22)
        sizes[type] = size
        return size
    }
    
    
    // MARK: - Cell
    
    private class Cell: UICollectionViewCell {
        
        private let label: UILabel = {
            let label = SpecialLabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .clear
            label.font = UIFont(name: "Gotham-Bold", size: 10) ?? UIFont.systemFont(ofSize: 10)
            label.textColor = .white
            label.kern = 1
            return label
        }()
        
        private let button: UIButton = {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .clear
            button.setImage(UIImage(named: "delete_white"), for: .normal)
            return button
        }()
        
        var remove: (()->())?
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            backgroundColor = .clear
            
            contentView.backgroundColor = UIColor(red: 12, green: 12, blue: 12)
            contentView.layer.cornerRadius = 11
            contentView.layer.masksToBounds = true
            
            contentView.addSubview(label)
            contentView.addSubview(button)
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 38).isActive = true
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            button.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 22).isActive = true
            
            contentView.layoutIfNeeded()
            
            button.addTarget(self, action: #selector(buttonTouch), for: .touchUpInside)
        }
        
        @objc private func buttonTouch() {
            remove?()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for text: String) {
            label.text = text
        }
        
        class func size(for text: String) -> CGFloat {
            let font = UIFont(name: "Gotham-Bold", size: 10) ?? UIFont.systemFont(ofSize: 10)
            return text.width(withConstrainedHeight: 22, font: font) + 22 + 2 * 16
        }
        
    }
    
}
