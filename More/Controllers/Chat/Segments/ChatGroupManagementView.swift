//
//  ChatGroupManagementView.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit
import SwipeCellKit

private let userCell = "UserCell"

class ChatGroupManagementView: LoadableView, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var titleLabel: UIView!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private var canDelete: Bool = false
    private var requests: [ShortUser] = []
    private var members: [ShortUser] = []
    
    var close: (()->())?
    var add: (()->())?
    var selectedUser: ((_ user: ShortUser)->())?
    var addUser: ((_ user: ShortUser)->())?
    var removeUser: ((_ user: ShortUser)->())?
    
    override func setupNib() {
        super.setupNib()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UserCell.self, forCellReuseIdentifier: userCell)
        tableView.sectionHeaderHeight = 52
        tableView.rowHeight = 61
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .zero
        tableView.separatorColor = .iceBlue
    }
    
    func setup(for chat: Chat, post: ExperiencePost?) {
        requests = post?.requests?.filter { $0.accepted == nil && !chat.members.contains($0.creator) }
            .map { $0.creator } ?? []
        members = chat.members.filter { !$0.isMe() }
        canDelete = chat.creator?.isMe() == true
        tableView.reloadData()
    }
    
    func setup(for users: [ShortUser]) {
        requests = []
        members = users.filter { !$0.isMe() }
        tableView.reloadData()
    }
    
    @IBAction private func closeTouch(_ sender: Any) {
        close?()
    }
    
    @IBAction private func addTouch(_ sender: Any) {
        add?()
    }
    
    // MARK: - helpers
    
    var sectionCount: Int {
        var count = 0
        if !requests.isEmpty {
            count += 1
        }
        if !members.isEmpty {
            count += 1
        }
        return count
    }
    
    func sectionRows(_ section: Int) -> [ShortUser] {
        if sectionIsRequest(section) {
            return requests
        }
        return members
    }
    
    func sectionIsRequest(_ section: Int) -> Bool {
        if section == 0 {
            if !requests.isEmpty {
                return true
            }
        }
        return false
    }
    
    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionRows(section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rows = sectionRows(indexPath.section)
        if indexPath.row < rows.count,
            let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath) as? UserCell {
            let user = rows[indexPath.row]
            cell.setup(for: user, request: sectionIsRequest(indexPath.section))
            cell.addTap = { [weak self] in
                self?.addUser?(user)
            }
            cell.delegate = self
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rows = sectionRows(indexPath.section)
        if indexPath.row < rows.count {
            selectedUser?(rows[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView(sectionIsRequest(section) ? "Requests" : "Members")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        guard !sectionIsRequest(indexPath.section) else { return nil }
        guard canDelete else { return nil }

        let deleteAction = SwipeAction(style: .default, title: "Delete") { [weak self] action, indexPath in
            guard let user = self?.sectionRows(indexPath.section)[indexPath.row] else { return }
            self?.removeUser?(user)
        }
        deleteAction.title = "Remove"
        deleteAction.textColor = .whiteThree
        deleteAction.font = UIFont(name: "Gotham-Bold", size: 13)
        deleteAction.backgroundColor = .scarlet

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .border
        return options
    }
    
    // MARK: - header
    
    private class HeaderView: UIView {
        private let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .clear
            label.font = UIFont(name: "Gotham-Medium", size: 15)
            label.textColor = .blueGrey
            label.textAlignment = .left
            return label
        }()
        
        convenience init(_ text: String) {
            self.init()
            setup(for: text)
        }
        
        private func setup(for text: String) {
            
            backgroundColor = UIColor(red: 241, green: 242, blue: 244)
            
            addSubview(label)
            
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            setNeedsLayout()
            
            label.text = text
        }
    }
    
    // MARK: - cell
    
    private class UserCell: SwipeTableViewCell {
        
        private let avatar: AvatarImage = {
            let avatar = AvatarImage()
            avatar.translatesAutoresizingMaskIntoConstraints = false
            avatar.backgroundColor = .clear
            return avatar
        }()
        
        private let name: UILabel = {
            let name = UILabel()
            name.translatesAutoresizingMaskIntoConstraints = false
            name.backgroundColor = .clear
            name.font = UIFont(name: "Gotham-Medium", size: 13)
            name.textColor = .charcoalGrey
            name.textAlignment = .left
            return name
        }()
        
        private let add: UIButton = {
            let add = UIButton()
            add.translatesAutoresizingMaskIntoConstraints = false
            add.backgroundColor = .clear
            add.setTitle("ADD", for: .normal)
            add.setTitleColor(.cornflower, for: .normal)
            add.titleLabel?.font = UIFont(name: "Gotham-Bold", size: 11)
            add.titleLabel?.textAlignment = .center
            add.layer.borderColor = UIColor.cornflower.cgColor
            add.layer.borderWidth = 2
            add.layer.cornerRadius = 18
            return add
        }()
        
        private let away: UILabel = {
            let away = UILabel()
            away.translatesAutoresizingMaskIntoConstraints = false
            away.backgroundColor = .clear
            away.font = UIFont(name: "Gotham-Bold", size: 9)
            away.textColor = .blueGrey
            away.textAlignment = .left
            return away
        }()
        
        private let walking: UIImageView = {
            let walking = UIImageView()
            walking.translatesAutoresizingMaskIntoConstraints = false
            walking.backgroundColor = .clear
            walking.contentMode = .scaleAspectFit
            walking.image = UIImage(named: "walking")
            return walking
        }()
        
        var addTap: (()->())?
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }
        
        private func setup() {
            backgroundColor = UIColor(red: 255, green: 255, blue: 255)
            contentView.backgroundColor = UIColor(red: 255, green: 255, blue: 255)
            
            contentView.addSubview(avatar)
            contentView.addSubview(name)
            contentView.addSubview(add)
            contentView.addSubview(away)
            contentView.addSubview(walking)
            
            avatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
            avatar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            avatar.widthAnchor.constraint(equalToConstant: 34).isActive = true
            avatar.heightAnchor.constraint(equalToConstant: 34).isActive = true
            
            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12).isActive = true
            name.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            
            add.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
            add.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            add.widthAnchor.constraint(equalToConstant: 68).isActive = true
            add.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            walking.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
            walking.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            walking.widthAnchor.constraint(equalToConstant: 11).isActive = true
            walking.heightAnchor.constraint(equalToConstant: 15).isActive = true
            
            away.trailingAnchor.constraint(equalTo: walking.leadingAnchor, constant: -10).isActive = true
            away.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            
            contentView.setNeedsLayout()
            
            add.addTarget(self, action: #selector(addTouch), for: .touchUpInside)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        @objc private func addTouch() {
            addTap?()
        }
        
        func setup(for user: ShortUser, request: Bool) {
            avatar.sd_progressive_setImage(with: URL(string: user.avatar))
            name.text = user.name
            
            if request {
                away.isHidden = true
                walking.isHidden = true
                add.isHidden = false
            } else {
                away.isHidden = false
                walking.isHidden = false
                add.isHidden = true
                
                away.text = "..."
                loadDistance(from: user)
            }
        }
        
        private func loadDistance(from user: ShortUser) {
            guard let myId = ProfileService.shared.profile?.getId() else { return }
            GeoService.shared.getDistance(from: myId, to: user.id) { [weak self] (distance) in
                self?.away.text = "\(Formatting.formatFeetAway(distance.metersToFeet())) away"
            }
        }
    }
}
