//
//  AlertsViewController.swift
//  More
//
//  Created by Luko Gjenero on 18/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let itemCell = String(describing: AlertsViewTableViewCell.self)

class AlertsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var tableView: UITableView!
    
    private var activeItems: [AlertService.AlertItem] = []
    private var expiredItems: [AlertService.AlertItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        tableView.estimatedRowHeight = 84
        tableView.rowHeight = 84
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UINib(nibName: itemCell, bundle: nil), forCellReuseIdentifier: itemCell)
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: AlertService.Notifications.NewAlert, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: AlertService.Notifications.AlertsChanged, object: nil)
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: load alerts
        
    }
    
    // MARK: - data
    
    private var sections: [Section] = []
    private var sectionData: [[AlertService.AlertItem]] = []
    
    private enum Section: String {
        case active, expired
    }
    
    @objc private func reload() {
        let alerts = AlertService.shared.alerts
        
        var activeItems: [AlertService.AlertItem] = []
        var expiredItems: [AlertService.AlertItem] = []
        
        for alert in alerts {
            switch alert.type {
            case .request, .response:
                if alert.signal?.allExpired() == false {
                    activeItems.append(alert)
                } else {
                    expiredItems.append(alert)
                }
            case .review:
                if alert.time?.haveReviewed() == false {
                    activeItems.append(alert)
                } else {
                    expiredItems.append(alert)
                }
            case .signalMessage:
                if alert.signal?.allExpired() == false {
                    activeItems.append(alert)
                } else {
                    expiredItems.append(alert)
                }
            case .timeMessage:
                if alert.time?.haveReviewed() == false {
                    activeItems.append(alert)
                } else {
                    expiredItems.append(alert)
                }
            case .welcome:
                activeItems.append(alert)
            }
        }
        
        activeItems.sort { (lhs, rhs) -> Bool in
            return lhs.createdAt > rhs.createdAt
        }
        expiredItems.sort { (lhs, rhs) -> Bool in
            return lhs.createdAt > rhs.createdAt
        }
        
        self.activeItems = activeItems
        self.expiredItems = expiredItems
        
        processSectionData()
        tableView.reloadData()
    }
    
    private func processSectionData() {
        var sections: [Section] = []
        var sectionData: [[AlertService.AlertItem]] = []
        if activeItems.count > 0 {
            sections.append(.active)
            sectionData.append(activeItems)
        }
        if expiredItems.count > 0 {
            sections.append(.expired)
            sectionData.append(expiredItems)
        }
        self.sections = sections
        self.sectionData = sectionData
    }
    
    //  MARK: - tableview

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = sectionData[indexPath.section][indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as? AlertsViewTableViewCell {
            
            switch item.type {
            case .request, .response:
                cell.setupForRequest(item.request!, in: item.signal!)
            case .review:
                cell.setupForReview(in: item.time!)
            case .signalMessage:
                cell.setupForMessgae(item.message!, in: item.signal!)
            case .timeMessage:
                cell.setupForMessgae(item.message!, in: item.time!)
            case .welcome:
                cell.setupForWelcomeVideo()
            }
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = AlertsViewTableSectionHeader()
        header.setup(for: sections[section].rawValue.capitalized)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tc = tabBarController as? MoreTabBarController {
            tc.processAlert(sectionData[indexPath.section][indexPath.row])
        }
    }

}



