//
//  ReviewsViewController.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let reviewCell = String(describing: ReviewItemCell.self)

class ReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var header: ReviewsHeader!
    @IBOutlet private weak var tableView: UITableView!
    
    private var model: UserViewModel?
    private var rows: [ReviewViewModel] = []
    private var heights: [ReviewViewModel: CGFloat] = [:]
    
    var backTap: (()->())?
    
    var bottomPadding: CGFloat = 90 {
        didSet {
            updateInsets()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        header.backTap = { [weak self] in
            self?.backTap?()
        }
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UINib(nibName: reviewCell, bundle: nil), forCellReuseIdentifier: reviewCell)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setup(for model: UserViewModel) {
        self.model = model
        
        header.setup(for: model)

        rows = model.reviews.sorted(by: { (lhs, rhs) -> Bool in
            let lDate = lhs.time.endedAt ?? lhs.time.createdAt // ?? lhs.createdAt
            let rDate = rhs.time.endedAt ?? rhs.time.createdAt // ?? rhs.createdAt
            return lDate > rDate
        })
        tableView.reloadData()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateInsets()
    }
    
    private func updateInsets() {
        tableView.contentInset = UIEdgeInsets(top: view.safeAreaInsets.top + 100, left: 0, bottom: view.safeAreaInsets.bottom + bottomPadding, right: 0)
    }

    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: reviewCell, for: indexPath) as? ReviewItemCell {
            cell.setup(for: rows[indexPath.row])
            if indexPath.row % 2 == 1 {
                cell.backgroundColor = .clear
            } else {
                cell.backgroundColor = Colors.reviewItemOddBackground
            }
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height(for: rows[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        header.setupOffset(scrollView.contentOffset.y + scrollView.contentInset.top)
    }
    
    // MARK: - height cache
    
    private func clearHeightCache() {
        heights = [:]
    }
    
    private func height(for review: ReviewViewModel) -> CGFloat {
        
        if let height = heights[review] {
            return height
        }
        
        let height = calculateHeight(for: review)
        heights[review] = height
        return height
    }
    
    private func calculateHeight(for review: ReviewViewModel) -> CGFloat {
        return ReviewItemCell.size(for: review, in: tableView.frame.size).height
    }
    
}
