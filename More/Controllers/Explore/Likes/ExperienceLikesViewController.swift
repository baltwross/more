//
//  ExperienceLikesViewController.swift
//  More
//
//  Created by Luko Gjenero on 24/02/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit
import Firebase

private let bulkSize: Int = 50
private let likeCell = String(describing: ExperienceLikeViewCell.self)

class ExperienceLikesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var headerBackgorund: UIView!
    @IBOutlet private weak var topFade: FadeView!
    
    private var experience: Experience?
    private var lastLoad: DocumentSnapshot?
    private var hasMore: Bool = true
    private var rows: [ExperienceLike] = []
    
    var backTap: (()->())?
    var scrolling: (()->())?
    
    var bottomPadding: CGFloat = 90 {
        didSet {
            updateInsets()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        back.enableShadow(color: .black)
        
        topFade.orientation = .up
        topFade.color = UIColor.black.withAlphaComponent(0.5)
        headerBackgorund.alpha = 0
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UINib(nibName: likeCell, bundle: nil), forCellReuseIdentifier: likeCell)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateInsets()
    }
    
    private func updateInsets() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom + bottomPadding, right: 0)
    }
    
    @IBAction func backTouch(_ sender: Any) {
        backTap?()
    }
    
    func setup(for experience: Experience) {
        self.experience = experience
        loadLikes()
    }
    
    // MARK: - load likes
    
    private func loadLikes() {
        guard let experience = experience else { return }
        guard hasMore else { return }
        
        ExperienceService.shared.loadExperienceLikes(experienceId: experience.id, limit: bulkSize, startAfter: lastLoad) { [weak self] (likes, last, _) in
            if let likes = likes, likes.count > 0 {
                self?.rows.append(contentsOf: likes)
            }
            self?.lastLoad = last
            self?.hasMore = (likes?.count ?? 0) >= bulkSize
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.row < rows.count,
            let cell = tableView.dequeueReusableCell(withIdentifier: likeCell, for: indexPath) as? ExperienceLikeViewCell {
            let like = rows[indexPath.row]
            cell.setup(for: like)
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = rows[indexPath.row]
        showProfile(item: item)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrolling?()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUI(scrollView)
    }
    
    // MARK: - handle scrolling UI
    
    private func updateUI(_ scrollView: UIScrollView) {
        // TODO
    }
    
    // MARK: - navigation
    
    private func showProfile(item: ExperienceLike) {
        let userId = item.creator.id
        navigationController?.showLoading()
        ProfileService.shared.loadProfile(withId: userId) { [weak self] (user, errorMsg) in
            self?.navigationController?.hideLoading()
            if let user = user {
                let vc = ProfileViewController()
                vc.backTap = {
                    self?.navigationController?.popViewController(animated: true)
                }
                vc.moreTap = { [weak self] in
                    self?.navigationController?.report(user.shortUser)
                }
                _ = vc.view
                vc.setup(for: UserViewModel(profile: user))
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
