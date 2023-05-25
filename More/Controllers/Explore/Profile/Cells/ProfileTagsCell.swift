//
//  ProfileTagsCell.swift
//  More
//
//  Created by Luko Gjenero on 19/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ProfileTagsCell: ProfileBaseCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private static let cellIdentifier = "TagCell"
    
    static let height: CGFloat = 130
    
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var tags: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tags.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        tags.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        tags.register(Cell.self, forCellWithReuseIdentifier: ProfileTagsCell.cellIdentifier)
        tags.dataSource = self
        tags.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private var tagList: [Review.Tag: Int] = [:]
    
    // MARK: - base
    
    override func setup(for model: UserViewModel) {
        
        tagList = model.tags
        
        tags.collectionViewLayout.invalidateLayout()
        tags.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tags.layoutIfNeeded()
        tags.collectionViewLayout.invalidateLayout()
        tags.reloadData()
    }
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: ProfileTagsCell.height)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return model.tags.count > 0
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileTagsCell.cellIdentifier, for: indexPath) as? Cell {
            let label = Array(tagList.keys)[indexPath.item]
            let count = tagList[label] ?? 0
            cell.setup(label: label.rawValue.capitalized, count: count)
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label = Array(tagList.keys)[indexPath.item]
        let count = tagList[label] ?? 0
        let size = TagView.size(label: label.rawValue.capitalized, count: count, in: collectionView.bounds.size)
        
        return CGSize(width: size.width, height: collectionView.bounds.size.height)
    }
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        private let tagView: TagView = {
            let tagView = TagView(frame: .zero)
            tagView.translatesAutoresizingMaskIntoConstraints = false
            tagView.backgroundColor = .whiteThree
            return tagView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(tagView)
            tagView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            tagView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            tagView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            tagView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7).isActive = true
            contentView.setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(label: String, count: Int) {
            tagView.setup(label: label, count: count)
        }
    }
    
}

