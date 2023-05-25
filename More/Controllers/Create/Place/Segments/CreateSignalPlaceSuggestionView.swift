//
//  CreateSignalPlaceSuggestionView.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let cellIdentifier = "Cell"

@IBDesignable
class CreateSignalPlaceSuggestionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var items: [ExperiencePlaceSuggestion] = []
    private(set) var selectedItem: ExperiencePlaceSuggestion? = nil
    
    var selected: ((_ item: ExperiencePlaceSuggestion)->())?
    
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
        register(Cell.self, forCellWithReuseIdentifier: cellIdentifier)
        dataSource = self
        delegate = self
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: SignalSuggestionsService.Notifications.SuggestionsLoaded, object: nil)
        refresh()
    }
    
    private var cellSize: CGSize {
        return CGSize(width: floor(frame.height / 0.7), height: frame.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layoutIfNeeded()
            let itemSize = cellSize
            if itemSize.width != layout.itemSize.width || itemSize.height != layout.itemSize.height {
                layout.itemSize = itemSize
                collectionViewLayout.invalidateLayout()
                reloadData()
            }
        }
    }
    
    func setup(for items: [ExperiencePlaceSuggestion]) {
        self.selectedItem = nil
        self.items = items
        reloadData()
    }
    
    func deselect() {
        self.selectedItem = nil
        reloadData()
    }
    
    @objc private func refresh() {
        setup(for: SignalSuggestionsService.shared.suggestions)
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < items.count,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? Cell {
            let item = items[indexPath.item]
            cell.setup(for: item, selected: item == selectedItem)
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = items[indexPath.item]
        selected?(items[indexPath.item])
        reloadData()
    }
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        private let image: UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.clipsToBounds = true
            image.backgroundColor = .clear
            image.layer.masksToBounds = true
            return image
        }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "Gotham-Bold", size: 11)
            label.textColor = .darkGrey
            label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
            label.textAlignment = .center
            label.layer.cornerRadius = 11
            label.layer.masksToBounds = true
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(image)
            contentView.addSubview(label)
            
            image.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            image.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 0).isActive = true
            image.widthAnchor.constraint(equalTo: image.heightAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11).isActive = true
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            contentView.setNeedsLayout()
            
            enableShadow(color: .black)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            image.layer.cornerRadius = min(frame.width, frame.height - 11) / 2
        }
        
        
        func setup(for suggestion: ExperiencePlaceSuggestion, selected: Bool) {
            if let urlStr = suggestion.image?.url, let url = URL(string: urlStr) {
                image.sd_progressive_setImage(with: url)
            } else {
                // TODO: - set image with first letter of name capitalized
            }
            
            label.text = suggestion.name
            
            if selected {
                label.textColor = UIColor(red: 255, green: 255, blue: 255)
                label.backgroundColor = .black
            } else {
                label.textColor = .black
                label.backgroundColor = UIColor(red: 255, green: 255, blue: 255)
            }
        }
    }

}
