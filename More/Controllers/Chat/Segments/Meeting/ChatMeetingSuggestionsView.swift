//
//  ChatMeetingSuggestionsView.swift
//  More
//
//  Created by Luko Gjenero on 13/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let cellIdentifier = "Cell"

@IBDesignable
class ChatMeetingSuggestionsView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var items: [MeetType] = [.halfway, .near, .destination] {
        didSet {
            reloadData()
        }
    }
    private(set) var selectedItem: MeetType? = nil
    
    var selected: ((_ item: MeetType)->())?
    
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
        contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 30
            layout.minimumInteritemSpacing = 30
        }
    }
    
    private var cellSize: CGSize {
        return CGSize(width: 114, height: frame.height)
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
    
    func select(type: MeetType) {
        selectedItem = type
        reloadData()
    }
    
    func deselect() {
        self.selectedItem = nil
        reloadData()
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
            image.backgroundColor = UIColor.iceBlue.withAlphaComponent(0.5)
            image.contentMode = .center
            image.layer.cornerRadius = 30
            image.layer.masksToBounds = true
            return image
        }()
        
        private let bubble: UIView = {
            let bubble = UIView()
            bubble.translatesAutoresizingMaskIntoConstraints = false
            bubble.backgroundColor = .whiteThree
            bubble.layer.cornerRadius = 11
            bubble.enableShadow(color: .black)
            return bubble
        }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "Gotham-Bold", size: 11)
            label.textColor = .darkGrey
            label.backgroundColor = .clear
            label.textAlignment = .center
            return label
        }()
        
        private let info: UILabel = {
            let info = UILabel()
            info.translatesAutoresizingMaskIntoConstraints = false
            info.font = UIFont(name: "Gotham-Medium", size: 12)
            info.textColor = .blueGrey
            info.backgroundColor = .clear
            info.textAlignment = .left
            info.numberOfLines = 2
            return info
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(image)
            contentView.addSubview(bubble)
            contentView.addSubview(info)
            bubble.addSubview(label)
            
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25).isActive = true
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            image.widthAnchor.constraint(equalToConstant: 60).isActive = true
            image.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 9).isActive = true
            bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -9).isActive = true
            bubble.topAnchor.constraint(equalTo: image.bottomAnchor, constant: -11).isActive = true
            bubble.heightAnchor.constraint(equalToConstant: 22).isActive = true
            
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor).isActive = true
            label.topAnchor.constraint(equalTo: bubble.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor).isActive = true
            
            info.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            info.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            info.topAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 15).isActive = true
            
            contentView.setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
        func setup(for type: MeetType, selected: Bool) {
            contentView.isHidden = false
            switch type {
            case .destination:
                image.image = UIImage(named: "time-meet-destination")
                label.text = "DESTINATION"
                info.text = "Meet at your final destination."
            case .halfway:
                image.image = UIImage(named: "time-meet-halfway")
                label.text = "HALFWAY"
                info.text = "Everyone walks to a central midpoint."
            case .near:
                image.image = UIImage(named: "time-meet-near")
                label.text = "NEAR ME"
                info.text = "Meet near your location."
            default:
                contentView.isHidden = true
            }
            
            if selected {
                label.textColor = UIColor(red: 255, green: 255, blue: 255)
                bubble.backgroundColor = .black
            } else {
                label.textColor = .black
                bubble.backgroundColor = UIColor(red: 255, green: 255, blue: 255)
            }
        }
    }

}

