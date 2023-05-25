//
//  RequestFormGroupUserSelectionView.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let userCell = "UserCell"
private let addUserCell = "AddUserCell"

class RequestFormGroupUserSelectionView: UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    private var type: SignalType = .adventurous
    private var users: [ShortUser] = []
    private var selectedUsers: [ShortUser] = []

    var selectionChanged: ((_ selected: [ShortUser])->())?
    var addTap: (()->())?
    
    convenience init() {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        register(UserCell.self, forCellWithReuseIdentifier: userCell)
        register(AddUserCell.self, forCellWithReuseIdentifier: addUserCell)
        delegate = self
        dataSource = self
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 23
            layout.minimumInteritemSpacing = 23
        }
    }
    
    private var cellSize: CGSize {
        return CGSize(width: 64, height: 90)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layoutIfNeeded()
            let itemSize = cellSize
            if !itemSize.equalTo(layout.itemSize) {
                layout.itemSize = itemSize
                collectionViewLayout.invalidateLayout()
                reloadData()
            }
        }
    }
    
    func setup(for users: [ShortUser], type: SignalType, selected: [ShortUser] = []) {
        self.selectedUsers = selected
        self.users = users
        self.type = type
        reloadData()
    }
    
    private func insertCells(at indicies: [Int]) {
        insertItems(at: indicies.map({ IndexPath(item: $0, section: 0) }))
    }
    
    private func deleteCells(at indicies: [Int]) {
        deleteItems(at: indicies.map({ IndexPath(item: $0, section: 0) }))
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < users.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCell, for: indexPath) as? UserCell {
                let user = users[indexPath.item]
                cell.setup(for: user, type: type, selected: selectedUsers.contains(user))
                return cell
            }
        } else if indexPath.item == users.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addUserCell, for: indexPath) as? AddUserCell {
                return cell
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < users.count  {
            let user = users[indexPath.item]
            if let idx = selectedUsers.firstIndex(of: user) {
                selectedUsers.remove(at: idx)
            } else {
                selectedUsers.append(user)
            }
            collectionView.reloadData()
            selectionChanged?(selectedUsers)
        } else if indexPath.item == users.count {
            addTap?()
        }
    }
    
    // MARK: - user cell
    
    private class UserCell: UICollectionViewCell {
        
        private let avatar: TimeAvatarView = {
            let avatar = TimeAvatarView()
            avatar.translatesAutoresizingMaskIntoConstraints = false
            avatar.clipsToBounds = true
            avatar.backgroundColor = .clear
            return avatar
        }()
        
        private let name: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "Avenir-Heavy", size: 11)
            label.textColor = .blueGrey
            label.backgroundColor = .clear
            return label
        }()
        
        private let badge: UIButton = {
            let badge = UIButton(type: .custom)
            badge.translatesAutoresizingMaskIntoConstraints = false
            badge.isUserInteractionEnabled = false
            badge.imageView?.contentMode = .center
            badge.setImage(UIImage.onePixelImage(color: .clear), for: .normal)
            badge.setImage(UIImage(named: "requests-tick-white"), for: .selected)
            badge.layer.borderWidth = 1
            badge.layer.borderColor = UIColor(red: 191, green: 195, blue: 202).cgColor
            badge.layer.cornerRadius = 10
            badge.layer.masksToBounds = true
            return badge
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            layer.masksToBounds = true
            
            contentView.addSubview(avatar)
            contentView.addSubview(name)
            contentView.addSubview(badge)
            
            avatar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor).isActive = true
            avatar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            avatar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26).isActive = true
            
            name.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            name.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            name.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            badge.topAnchor.constraint(equalTo: avatar.topAnchor).isActive = true
            badge.trailingAnchor.constraint(equalTo: avatar.trailingAnchor).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 20).isActive = true
            badge.widthAnchor.constraint(equalToConstant: 20).isActive = true
            contentView.setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for user: ShortUser, type: SignalType, selected: Bool) {
            avatar.imageUrl = user.avatar
            avatar.type = type
            avatar.progress = 1
            name.text = user.name
            badge.isSelected = selected
            badge.backgroundColor = selected ? .brightSkyBlue : .whiteTwo
            badge.layer.borderWidth = selected ? 0 : 1
        }
    }
    
    // MARK: - add user cell
    
    private class AddUserCell: UICollectionViewCell {
        
        private let image: UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.backgroundColor = UIColor(red: 241, green: 242, blue: 244)
            image.layer.masksToBounds = true
            image.contentMode = .center
            image.image = UIImage(named: "requests-add-user")
            return image
        }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "Avenir-Heavy", size: 11)
            label.textColor = .blueGrey
            label.backgroundColor = .clear
            label.text = "Add Friends"
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(image)
            contentView.addSubview(label)
            
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            image.widthAnchor.constraint(equalTo: image.heightAnchor).isActive = true
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7).isActive = true
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -33).isActive = true
            
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 20).isActive = true
            contentView.setNeedsLayout()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            image.layer.cornerRadius = (bounds.height - 40) / 2
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

}
