//
//  OwnProfileViewController.swift
//  More
//
//  Created by Luko Gjenero on 15/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

private let photosCell = String(describing: ProfilePhotosCell.self)
private let userCell = String(describing: ProfileUserCell.self)
private let quoteCell = String(describing: ProfileQuoteCell.self)
private let tagsCell = String(describing: ProfileTagsCell.self)
private let pastCell = String(describing: ProfilePastExperiencesCell.self)
private let designedCell = String(describing: ProfileDesignedExperiencesCell.self)
private let momentCell = String(describing: ProfileMomentCell.self)

class OwnProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settings: UIButton!
    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var headerBackgorund: UIView!
    @IBOutlet private weak var fade: FadeView!
    
    private var model: UserViewModel?
    private var rows: [String] = []
    private var heights: [String: CGFloat] = [:]
    
    var backTap: (()->())? {
        didSet {
            if backTap == nil {
                back?.isHidden = true
            } else {
                back?.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        back.enableShadow(color: .black)
        settings.enableShadow(color: .black)
        
        setupTabBar()
        
        fade.orientation = .up
        fade.color = UIColor.black.withAlphaComponent(0.5)
        headerBackgorund.alpha = 0
        back.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.insetsContentViewsToSafeArea = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        tableView.register(UINib(nibName: photosCell, bundle: nil), forCellReuseIdentifier: photosCell)
        tableView.register(UINib(nibName: userCell, bundle: nil), forCellReuseIdentifier: userCell)
        tableView.register(UINib(nibName: quoteCell, bundle: nil), forCellReuseIdentifier: quoteCell)
        tableView.register(UINib(nibName: tagsCell, bundle: nil), forCellReuseIdentifier: tagsCell)
        tableView.register(UINib(nibName: pastCell, bundle: nil), forCellReuseIdentifier: pastCell)
        tableView.register(UINib(nibName: designedCell, bundle: nil), forCellReuseIdentifier: designedCell)
        tableView.register(UINib(nibName: momentCell, bundle: nil), forCellReuseIdentifier: momentCell)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: ProfileService.Notifications.ProfileLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: ProfileService.Notifications.ProfilePhotos, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nc = navigationController as? MoreTabBarNestedNavigationController {
            nc.hideNavigation(hide: true, animated: false)
        }
        reload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        clearHeightCache()
        tableView.reloadData()
    }
    
    private func setupTabBar() {
        hidesBottomBarWhenPushed = true
    }
    
    @IBAction private func backTouch(_ sender: Any) {
        backTap?()
    }
    
    @IBAction private func settingsTouch(_ sender: Any) {
        presentSettings()
    }
    
    @objc private func reload() {
        if let model = ProfileService.shared.userModel() {
            self.model = model
            setup(for: model)
        }
    }
    
    private func setup(for model: UserViewModel) {
        self.model = model
        
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
        if ProfilePastExperiencesCell.isShowing(for: model) {
            rows.append(pastCell)
        }
        if ProfileDesignedExperiencesCell.isShowing(for: model) {
            rows.append(designedCell)
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
            if let cell = cell as? ProfilePhotosCell, identifier == photosCell {
                cell.placeholder = model.imageUrls.count > 0 ? nil : UIImage(named: "no_photo")
                cell.editTap = { [weak self] in
                    let vc = EditProfileViewController()
                    _ = vc.view
                    vc.doneTap = { [weak self] in
                        self?.navigationController?.popViewController(animated: true, subType: .fromRight)
                    }
                    self?.navigationController?.pushViewController(vc, animated: true, subType: .fromLeft)
                }
            }
            if let cell = cell as? ProfilePastExperiencesCell {
                cell.setup(separateBottom: model.numOfDesigned == 0)
            }
            
            cell.setup(for: model)
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height(for: rows[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = rows[indexPath.row]
        if identifier == pastCell {
            let nc = MoreTabBarNestedNavigationController()
            let vc = PastExperiencesViewController()
            nc.setViewControllers([vc], animated: false)
            present(nc, animated: true, completion: nil)
        } else if identifier == designedCell {
            let nc = MoreTabBarNestedNavigationController()
            let vc = DesignedExperiencesViewController()
            nc.setViewControllers([vc], animated: false)
            present(nc, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUI(scrollView)
    }
    
    // MARK: - handle scrolling UI
    
    private func updateUI(_ scrollView: UIScrollView) {
        let photoHeight = height(for: photosCell)
        let headerBreak = photoHeight - 50 - view.safeAreaInsets.top
        let progress = min(1, max(0, (scrollView.contentOffset.y - headerBreak) / 50))
        headerBackgorund.alpha = progress
        
        let color = UIColor.whiteTwo.interpolateRGB(to: .blueGrey, fraction: progress)
        back.tintColor = color
        settings.tintColor = color
    }

    private func getPhoto() -> UIView? {
        if let photoCell = tableView.visibleCells.first(where: { $0 is ProfilePhotosCell }) as? ProfilePhotosCell {
            return photoCell.currentPhoto()
        }
        return nil
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
        case pastCell:
            return ProfilePastExperiencesCell.size(for: model, in: tableView.frame.size).height
        case designedCell:
            return ProfileDesignedExperiencesCell.size(for: model, in: tableView.frame.size).height
        case momentCell:
            return ProfileMomentCell.size(for: model, in: tableView.frame.size).height
        default:
            return 0
        }
    }
}
    
// MARK: - settings
extension OwnProfileViewController: SFSafariViewControllerDelegate  {
    
    fileprivate func presentSettings() {
        
        let vc = SettingsViewController()
        
        vc.closeTap = { [weak vc] in
            vc?.view.removeFromSuperview()
            vc?.removeFromParent()
        }
        
        vc.inviteTap = { [weak self] in
            if let sself = self {
                ShareService.shareInvite(from: sself)
            }
        }
        
        vc.supportTap = { [weak self] in
            guard MFMailComposeViewController.canSendMail() else { return }
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Support")
            mail.setToRecipients([Emails.support])
            self?.present(mail, animated: true, completion: { })
        }
        
        vc.termsTap = { [weak self] in
            guard let url = URL(string: Urls.terms) else { return }
            
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            self?.present(vc, animated: true)
        }
        
        vc.privacyTap = { [weak self] in
            guard let url = URL(string: Urls.privacy) else { return }
            
            let vc = SFSafariViewController(url: url)
            vc.delegate = self
            self?.present(vc, animated: true)
        }
        
        vc.logoutTap = { [weak self] in
            ProfileService.shared.logout(complete: { (success, errorMsg) in
                if success {
                    let login = LoginNavigationController()
                    AppDelegate.appDelegate()?.transitionRootViewController(viewController: login, animated: true, completion: nil)
                } else {
                    self?.errorAlert(text: errorMsg ?? "Unknown error")
                }
            })
        }
        
        vc.deleteTap = { [weak self] in
            
            let alert = UIAlertController(
                title: "Delete Account",
                message: "Are you sure you want to delete your account? All your data will be lost forever.",
                preferredStyle: .actionSheet)

            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                ProfileService.shared.deleteAccount(complete: { (success, errorMsg) in
                    if success {
                        let login = LoginNavigationController()
                        AppDelegate.appDelegate()?.transitionRootViewController(viewController: login, animated: true, completion: nil)
                    } else {
                        self?.errorAlert(text: errorMsg ?? "Unknown error")
                    }
                })
            })
            
            alert.addAction(delete)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        view.setNeedsLayout()
        vc.viewDidAppear(false)
        
        /*
        settingsShowing = true
        setNeedsStatusBarAppearanceUpdate()
        */
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
