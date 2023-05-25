//
//  RequestFormGroupViewController.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let cellIdentifier = "Cell"

class RequestFormGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var panel: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var button: BottomButton!
    @IBOutlet private weak var tableViewHeight: NSLayoutConstraint!

    private var models: [CellModel] = []

    var formGroup: ((_ post: ExperiencePost, _ users: [ShortUser])->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panel.layer.cornerRadius = 12
        panel.enableShadow(color: .black)
        
        tableView.register(Cell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
        button.isDisabled = true
        button.tap = { [weak self] in
            self?.buttonTap()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayout()
    }
    
    func setup(for posts: [ExperiencePost]) {
        self.models = posts.map { CellModel($0) }
        tableView.reloadData()
        updateLayout()
    }
    
    private func updateLayout() {
        let maxHeight = view.bounds.height - view.safeAreaInsets.top - button.bounds.height - 28
        tableViewHeight.constant = min(tableView.contentSize.height, maxHeight)
    }
    
    private func updateButton() {
        if models.first(where: { $0.selectedUsers.count > 1}) != nil {
            button.isDisabled = false
        } else {
            button.isDisabled = true
        }
    }
    
    private func updateModelSelection(model: CellModel?, selection: [ShortUser]) {
        guard let model = model else { return }
        
        if let cellModel = models.first(where: { $0.post.id == model.post.id }) {
            cellModel.selectedUsers = selection
            if selection.count > 1 {
                for otherModel in models {
                    if otherModel.post.id != model.post.id {
                        otherModel.selectedUsers = []
                    }
                }
            }
        }
    }
    
    // MARK: - Form froup
    
    private func buttonTap() {
        for model in models {
            if !model.selectedUsers.isEmpty {
                formGroup?(model.post, model.selectedUsers)
                return
            }
        }
    }
    
    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row < models.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell {
                let model = models[indexPath.row]
                cell.setup(for: models[indexPath.row])
                cell.selectionChanged = { [weak self, weak model] selection in
                    self?.updateModelSelection(model: model, selection: selection)
                    self?.tableView.reloadData()
                    self?.updateButton()
                }
                return cell
            }
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - cell data model
    
    private class CellModel {
        let post: ExperiencePost
        var selectedUsers: [ShortUser] = []
        
        init(_ post: ExperiencePost) {
            self.post = post
        }
    }
    
    // MARK: - cell
    
    private class Cell: UITableViewCell {
        
        private let titleView: UILabel = {
            let titleView = UILabel()
            titleView.translatesAutoresizingMaskIntoConstraints = false
            titleView.backgroundColor = .clear
            titleView.textColor = .charcoalGrey
            titleView.font = UIFont(name: "Gotham-Medium", size: 16)
            titleView.numberOfLines = 2
            return titleView
        }()
        
        private let requestNumView: UILabel = {
            let requestNumView = UILabel()
            requestNumView.translatesAutoresizingMaskIntoConstraints = false
            requestNumView.backgroundColor = .clear
            requestNumView.textColor = .blueGrey
            requestNumView.font = UIFont(name: "Gotham-Medium", size: 11)
            return requestNumView
        }()
        
        private let selector: RequestFormGroupUserSelectionView = {
            let selector = RequestFormGroupUserSelectionView()
            selector.translatesAutoresizingMaskIntoConstraints = false
            selector.backgroundColor = .clear
            return selector
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }

        var selectionChanged: ((_ selected: [ShortUser])->())?
        var addTap: (()->())?
        
        private func setup() {
            contentView.addSubview(titleView)
            contentView.addSubview(requestNumView)
            contentView.addSubview(selector)
            
            titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25).isActive = true
            titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25).isActive = true
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
            
            requestNumView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25).isActive = true
            requestNumView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10).isActive = true
            
            selector.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            selector.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            selector.topAnchor.constraint(equalTo: requestNumView.bottomAnchor, constant: 15).isActive = true
            selector.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
            selector.heightAnchor.constraint(equalToConstant: 90).isActive = true
            
            contentView.setNeedsLayout()
            
            selectionStyle = .none
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        func setup(for model: CellModel) {
            
            titleView.text = model.post.title
            requestNumView.text = "\(model.post.requests?.count ?? 0) REQUESTS"
            
            let users: [ShortUser] = model.post.requests?.map { $0.creator } ?? []
            selector.setup(for: users, type: model.post.experience.type, selected: model.selectedUsers)
            
            selector.selectionChanged = { [weak self] (selection) in
                self?.selectionChanged?(selection)
            }
        }
    }
}


