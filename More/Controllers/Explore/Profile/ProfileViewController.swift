//
//  ProfileViewController.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let photosCell = String(describing: ProfilePhotosCell.self)
private let userCell = String(describing: ProfileUserCell.self)
private let quoteCell = String(describing: ProfileQuoteCell.self)
private let tagsCell = String(describing: ProfileTagsCell.self)
private let reportCell = String(describing: ProfileReportCell.self)
private let momentCell = String(describing: ProfileMomentCell.self)

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var more: UIButton!
    @IBOutlet private weak var headerBackgorund: UIView!
    @IBOutlet private weak var topFade: FadeView!
    
    private var model: UserViewModel?
    private var rows: [String] = []
    private var heights: [String: CGFloat] = [:]
    
    var backTap: (()->())?
    
    var moreTap: (()->())?
    
    var scrolling: (()->())?
    
    var bottomPadding: CGFloat = 90 {
        didSet {
            updateInsets()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        back.enableShadow(color: .black)
        more.enableShadow(color: .black)
        
        topFade.orientation = .up
        topFade.color = UIColor.black.withAlphaComponent(0.5)
        headerBackgorund.alpha = 0

        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UINib(nibName: photosCell, bundle: nil), forCellReuseIdentifier: photosCell)
        tableView.register(UINib(nibName: userCell, bundle: nil), forCellReuseIdentifier: userCell)
        tableView.register(UINib(nibName: quoteCell, bundle: nil), forCellReuseIdentifier: quoteCell)
        tableView.register(UINib(nibName: tagsCell, bundle: nil), forCellReuseIdentifier: tagsCell)
        tableView.register(UINib(nibName: reportCell, bundle: nil), forCellReuseIdentifier: reportCell)
        tableView.register(UINib(nibName: momentCell, bundle: nil), forCellReuseIdentifier: momentCell)
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        clearHeightCache()
        tableView.reloadData()
    }
    
    @IBAction func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction func moreTouch(_ sender: Any) {
        moreTap?()
    }
    
    func setup(for model: UserViewModel) {
        self.model = model
        
        if model.user.isMe() {
            more.isHidden = true
        }
        
        rows = []
        
        if ProfilePhotosCell.isShowing(for: model) {
            rows.append(photosCell)
        }
        if ProfileUserCell.isShowing(for: model) {
            rows.append(userCell)
        }
        if ProfileQuoteCell.isShowing(for: model) {
            rows.append(quoteCell)
        }
        if ProfileTagsCell.isShowing(for: model) {
            rows.append(tagsCell)
        }
        if ProfileReportCell.isShowing(for: model) {
            rows.append(reportCell)
        }
        if ProfileMomentCell.isShowing(for: model) {
            rows.append(momentCell)
        }
        tableView.reloadData()
    }


    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = rows[indexPath.row]
        if let model = model,
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ProfileBaseCell {
            cell.setup(for: model)
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height(for: rows[indexPath.row])
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let identifier = rows[indexPath.row]
//    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrolling?()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUI(scrollView)
    }
    
    // MARK: - handle scrolling UI
    
    private func updateUI(_ scrollView: UIScrollView) {
        let headerBreak = height(for: photosCell) - 50 - view.safeAreaInsets.top
        let progress = min(1, max(0, (scrollView.contentOffset.y - headerBreak) / 50))
        headerBackgorund.alpha = progress
        
        let color = UIColor.whiteTwo.interpolateRGB(to: .blueGrey, fraction: progress)
        back.tintColor = color
        more.tintColor = color
    }
    
    // MARK: - height cache
    
    private func clearHeightCache() {
        heights = [:]
    }
    
    private func height(for identifier: String) -> CGFloat {
        
        guard model != nil else { return 0 }
        
        if let height = heights[identifier] {
            return height
        }
        
        let height = calculateHeight(for: identifier)
        heights[identifier] = height
        return height
    }
    
    private func calculateHeight(for identifier: String) -> CGFloat {
        
        guard let model = model else { return 0 }
        
        switch identifier {
        case photosCell:
            return ProfilePhotosCell.size(for: model, in: tableView.frame.size).height
        case userCell:
            return ProfileUserCell.size(for: model, in: tableView.frame.size).height
        case quoteCell:
            return ProfileQuoteCell.size(for: model, in: tableView.frame.size).height
        case tagsCell:
            return ProfileTagsCell.size(for: model, in: tableView.frame.size).height
        case reportCell:
            return ProfileReportCell.size(for: model, in: tableView.frame.size).height
        case momentCell:
            return ProfileMomentCell.size(for: model, in: tableView.frame.size).height
        default:
            return 0
        }
    }
}
