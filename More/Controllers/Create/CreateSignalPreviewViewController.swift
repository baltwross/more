//
//  CreateSignalPreviewViewController.swift
//  More
//
//  Created by Luko Gjenero on 31/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let photosCell = String(describing: SignalDetailsPhotosCell.self)
private let quoteCell = String(describing: SignalDetailsQuoteCell.self)
private let userCell = String(describing: SignalDetailsUserCell.self)
private let tipsCell = String(describing: SignalDetailsTipsCell.self)
private let mapCell = String(describing: SignalDetailsMapCell.self)

class CreateSignalPreviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var fade: FadeView!
    @IBOutlet private weak var headerBackgorund: UIView!
    @IBOutlet private weak var progress: UIProgressView!
    
    private var model: CreateExperienceViewModel?
    private var rows: [String] = []
    
    var backTap: (()->())?
    var reportTap: (()->())?
    var shareTap: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .fullScreen
        
        back.enableShadow(color: .black)
        
        fade.orientation = .up
        fade.color = UIColor.black.withAlphaComponent(0.5)
        headerBackgorund.alpha = 0
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UINib(nibName: photosCell, bundle: nil), forCellReuseIdentifier: photosCell)
        tableView.register(UINib(nibName: quoteCell, bundle: nil), forCellReuseIdentifier: quoteCell)
        tableView.register(UINib(nibName: userCell, bundle: nil), forCellReuseIdentifier: userCell)
        tableView.register(UINib(nibName: tipsCell, bundle: nil), forCellReuseIdentifier: tipsCell)
        tableView.register(UINib(nibName: mapCell, bundle: nil), forCellReuseIdentifier: mapCell)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        progress.isHidden = true
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom + 60, right: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.reloadData()
    }
    
    @IBAction func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction func shareTouch(_ sender: Any) {
        // TODO: - limit requests?
        shareTap?()
    }
    
    func setup(for model: CreateExperienceViewModel) {
        self.model = model
        
        rows = []
        
        if SignalDetailsPhotosCell.isShowing(for: model) {
            rows.append(photosCell)
        }
        if SignalDetailsQuoteCell.isShowing(for: model) {
            rows.append(quoteCell)
        }
        if SignalDetailsUserCell.isShowing(for: model) {
            rows.append(userCell)
        }
        if SignalDetailsTipsCell.isShowing(for: model) {
            rows.append(tipsCell)
        }
        if SignalDetailsMapCell.isShowing(for: model) {
            rows.append(mapCell)
        }
        
        tableView.reloadData()
    }
    
    func setProgress(_ progress: Float) {
        self.view.isUserInteractionEnabled = false
        self.progress.isHidden = false
        self.progress.progress = progress
    }
    
    func removeProgress() {
        self.view.isUserInteractionEnabled = true
        self.progress.isHidden = true
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
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SignalDetailsBaseCell {
            cell.setup(for: model)
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUI(scrollView)
    }
    
    // MARK: - handle scrolling UI
    
    private func updateUI(_ scrollView: UIScrollView) {
        var progress: CGFloat = 1
        if let photoCell = tableView.visibleCells.first(where: { $0 is SignalDetailsPhotosCell }) as? SignalDetailsPhotosCell {
            let height = photoCell.bounds.height
            let headerBreak = height - 50 - view.safeAreaInsets.top
            progress = min(1, max(0, (scrollView.contentOffset.y - headerBreak) / 50))
        }
        
        headerBackgorund.alpha = progress
        
        let color = UIColor.whiteTwo.interpolateRGB(to: .blueGrey, fraction: progress)
        back.tintColor = color
    }
    

}
