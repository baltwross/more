//
//  ActiveRequestsTableViewCell.swift
//  More
//
//  Created by Luko Gjenero on 28/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let userCell = "UserCell"
private let groupCell = "GroupCell"
private let createGroupCell = "CreateGroupCell"

class ActiveRequestsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var models: [UserCellModel] = []
    private var showCreateGroup: Bool = false
    
    var addGroupTap: (()->())?
    var requestTap: ((_ post: ExperiencePost, _ request: ExperienceRequest?)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: userCell)
        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: groupCell)
        collectionView.register(CreateGroupCell.self, forCellWithReuseIdentifier: createGroupCell)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemSize = self.itemSize
            if !itemSize.equalTo(layout.itemSize) {
                layout.itemSize = itemSize
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.reloadData()
            }
        }
    }
    
    private var itemSize: CGSize {
        return CGSize(width: 60, height: 90)
    }
    
    func setup(for posts: [ExperiencePost]) {
        showCreateGroup = false
        var models: [UserCellModel] = []
        
        for post in posts {
            if post.creator.isMe() {
                var show = true
                if post.chat != nil {
                    show = false
                    models.append(UserCellModel(post: post))
                }
                let postRequests = post.requests?.filter({ (request) -> Bool in
                    return request.accepted == nil &&
                        !(post.chat?.memberIds.contains(request.creator.id) == true)
                }) ?? []
                
                for request in postRequests {
                   models.append(UserCellModel(post: post, request: request))
                }
                if postRequests.count > 1 {
                    showCreateGroup = show
                }
            } else {
                if let chat = post.chat, chat.IamMember() {
                    models.append(UserCellModel(post: post))
                } else if let request = post.myRequest(), request.accepted == nil {
                    models.append(UserCellModel(post: post, request: request))
                }
            }
        }
        self.models = models
        collectionView.reloadData()
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count + (showCreateGroup ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var index = indexPath.item
        if showCreateGroup {
            if index == 0 {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: createGroupCell, for: indexPath) as? CreateGroupCell {
                    return cell
                }
                return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
            }
            index -= 1
        }
        
        let model = models[index]
        
        if model.request == nil {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: groupCell, for: indexPath) as? GroupCell {
                cell.setup(for: model)
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userCell, for: indexPath) as? UserCell {
                cell.setup(for: model)
                return cell
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var index = indexPath.item
        if showCreateGroup {
            if index == 0 {
                addGroupTap?()
                return
            }
            index -= 1
        }
        let model = models[index]
        requestTap?(model.post, model.request)
    }
    
    // MARK: - Cells
    
    private struct UserCellModel {
        let post: ExperiencePost
        let request: ExperienceRequest?
        
        init (post: ExperiencePost, request: ExperienceRequest) {
            self.post = post
            self.request = request
        }
        
        init (post: ExperiencePost) {
            self.post = post
            self.request = nil
        }
    }
    
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
            label.textAlignment = .center
            label.textColor = UIColor(red: 67, green: 74, blue: 81)
            label.backgroundColor = .clear
            return label
        }()
        
        private let badge: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "DIN-Bold", size: 13)
            label.textColor = .white
            label.backgroundColor = UIColor(red: 91, green: 200, blue: 250)
            label.textAlignment = .center
            label.layer.cornerRadius = 11.5
            label.layer.masksToBounds = true
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(avatar)
            contentView.addSubview(name)
            contentView.addSubview(badge)
            
            avatar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor).isActive = true
            avatar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            avatar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
            
            name.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            name.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            name.heightAnchor.constraint(equalToConstant: 20).isActive = true
            name.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: -8).isActive = true
            
            badge.topAnchor.constraint(equalTo: avatar.topAnchor, constant: -2).isActive = true
            badge.trailingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 2).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 21).isActive = true
            badge.widthAnchor.constraint(equalToConstant: 21).isActive = true
            contentView.setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for model: UserCellModel) {
            if let request = model.request {
                if request.creator.isMe() {
                    avatar.imageUrl = model.post.creator.avatar
                    name.text = model.post.creator.name
                } else {
                    avatar.imageUrl = request.creator.avatar
                    name.text = request.creator.name
                }
                avatar.setupRunningProgress(start: request.createdAt, end: model.post.expiresAt)
            }
            
            avatar.type = model.post.experience.type
            badge.backgroundColor = model.post.experience.type.color
            
            badge.isHidden = false
            
            let chat = ChatService.shared.getChat(for: model.request?.creator.id ?? "--")
            let unread = chat?.messages?.filter { !$0.isMine() && !$0.haveRead() } ?? []
            if unread.count > 0 {
                badge.isHidden = false
                badge.text = "\(unread.count)"
            } else {
                badge.isHidden = true
            }
        }
    }
    
    private class GroupCell: UICollectionViewCell {
        
        private let avatar: TimeAvatarView = {
            let avatar = TimeAvatarView()
            avatar.translatesAutoresizingMaskIntoConstraints = false
            avatar.clipsToBounds = true
            avatar.backgroundColor = .clear
            return avatar
        }()
        
        private let smallAvatar: TimeAvatarView = {
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
            label.textAlignment = .center
            label.textColor = UIColor(red: 67, green: 74, blue: 81)
            label.backgroundColor = .clear
            return label
        }()
        
        private let badge: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "DIN-Bold", size: 13)
            label.textColor = .white
            label.backgroundColor = UIColor(red: 91, green: 200, blue: 250)
            label.textAlignment = .center
            label.layer.cornerRadius = 11.5
            label.layer.masksToBounds = true
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(smallAvatar)
            contentView.addSubview(avatar)
            contentView.addSubview(name)
            contentView.addSubview(badge)
            
            smallAvatar.centerXAnchor.constraint(equalTo: avatar.centerXAnchor, constant: -17).isActive = true
            smallAvatar.centerYAnchor.constraint(equalTo: avatar.centerYAnchor, constant: -17).isActive = true
            smallAvatar.widthAnchor.constraint(equalTo: smallAvatar.heightAnchor).isActive = true
            smallAvatar.widthAnchor.constraint(equalTo: avatar.widthAnchor, multiplier: 0.7).isActive = true
            
            avatar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor).isActive = true
            avatar.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            avatar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
            
            name.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            name.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            name.heightAnchor.constraint(equalToConstant: 20).isActive = true
            name.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: -8).isActive = true
            
            badge.topAnchor.constraint(equalTo: avatar.topAnchor, constant: -2).isActive = true
            badge.trailingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 2).isActive = true
            badge.heightAnchor.constraint(equalToConstant: 21).isActive = true
            badge.widthAnchor.constraint(equalToConstant: 21).isActive = true
            contentView.setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for model: UserCellModel) {
            
            var notMe: [ShortUser] = []
            if !model.post.creator.isMe() {
                notMe.append(model.post.creator.short())
            }
            let noyMyRequests = model.post.requests?.filter { !$0.creator.isMe() && model.post.chat?.memberIds.contains($0.creator.id) == true } ?? []
            notMe.append(contentsOf: noyMyRequests.map { $0.creator })
            
            if let first = notMe.first {
                avatar.imageUrl = first.avatar
                avatar.type = model.post.experience.type
                avatar.progress = 1
            }
            
            if notMe.count > 1 {
                let second = notMe[1]
                smallAvatar.isHidden = false
                smallAvatar.imageUrl = second.avatar
                smallAvatar.type = model.post.experience.type
                smallAvatar.progress = 1
            } else {
                smallAvatar.isHidden = true
            }
        
            var text = "\(notMe.first?.name ?? "?")"
            if notMe.count > 1 {
                text += " + \(notMe.count - 1)"
            }
            name.text = text
            badge.backgroundColor = model.post.experience.type.color
            
            badge.isHidden = false
            
            let chat = ChatService.shared.getChat(for: model.request?.creator.id ?? "---")
            let unread = chat?.messages?.filter { !$0.isMine() && $0.haveRead() } ?? []
            if unread.count > 0 {
                badge.isHidden = false
                badge.text = "\(unread.count)"
            } else {
                badge.isHidden = true
            }
        }
    }
    
    private class CreateGroupCell: UICollectionViewCell {
        
        private let plusRatio: CGFloat = 0.8333
        private let smallCircleRatio: CGFloat = 0.5833
        
        private let plus: UIImageView = {
            let plus = UIImageView()
            plus.translatesAutoresizingMaskIntoConstraints = false
            plus.clipsToBounds = true
            plus.backgroundColor = .iceBlue
            plus.layer.borderColor = UIColor.whiteTwo.cgColor
            plus.layer.borderWidth = 4
            plus.layer.masksToBounds = true
            plus.contentMode = .center
            plus.image = UIImage(named: "requests-create-group")
            return plus
        }()
        
        private let smallCircle: UIView = {
            let smallCircle = UIView()
            smallCircle.translatesAutoresizingMaskIntoConstraints = false
            smallCircle.backgroundColor = .iceBlue
            smallCircle.layer.masksToBounds = true
            return smallCircle
        }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "Avenir-Heavy", size: 11)
            label.textAlignment = .center
            label.textColor = UIColor(red: 67, green: 74, blue: 81)
            label.backgroundColor = .clear
            label.text = "Form Group"
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(smallCircle)
            contentView.addSubview(plus)
            contentView.addSubview(label)
            
            plus.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            plus.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
            plus.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: plusRatio).isActive = true
            plus.heightAnchor.constraint(equalTo: plus.widthAnchor).isActive = true
            
            smallCircle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            smallCircle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
            smallCircle.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: smallCircleRatio).isActive = true
            smallCircle.heightAnchor.constraint(equalTo: smallCircle.widthAnchor).isActive = true
            
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 20).isActive = true
            label.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: -8).isActive = true
            label.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: 0).isActive = true
            
            contentView.setNeedsLayout()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            plus.layer.cornerRadius = (frame.width * plusRatio) / 2
            smallCircle.layer.cornerRadius = (frame.width * smallCircleRatio) / 2
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
