//
//  ReviewViewController.swift
//  More
//
//  Created by Luko Gjenero on 23/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SwiftMessages

class ReviewViewController: UIViewController {

    // ui
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var header: ReviewUserHeader!
    @IBOutlet private weak var headerHeight: NSLayoutConstraint!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var bottomBar: ReviewBottomBar!
    @IBOutlet private weak var container: UIView!
    
    // pages
    private let timePage = ReviewTimePage()
    private let userPage = ReviewUserPage()
    private let tagsPage = ReviewUserTagsPage()
    private let durationPage = ReviewDurationPage()
    private let commentPage = ReviewCommentPage()
    private let submittedPage = ReviewSubmittedPage()
    
    private lazy var pages: [ReviewPage] = [timePage, userPage, tagsPage, durationPage, commentPage, submittedPage]
    
    private var currentPage: ReviewPage? {
        if let view = container.subviews.first {
            for page in pages {
                if page.view == view {
                    return page
                }
            }
        }
        return nil
    }
    
    private var model: CreateReviewModel!
    
    var closeTap: (()->())?
    
    @IBAction func closeTouch(_ sender: Any) {
        closeTap?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        header.avatarTap = { [weak self] in
            if let userId = self?.model?.time.otherPerson().id {
                self?.presentUser(userId)
            }
        }
        
        header.timeTap = { [weak self] in
            if let signalId = self?.model?.time.signal.id {
                self?.presentSignal(signalId)
            }
        }
        
        bottomBar.backTap = { [weak self] in
            self?.back()
        }
        
        bottomBar.nextTap = { [weak self] in
            self?.next()
        }
        
        bottomBar.submitTap = { [weak self] in
            self?.submit()
        }
        
        
        // init pages
        for page in pages {
            _ = page.view
            page.dataChanged = { [weak self] in
                if let currentPage = self?.currentPage {
                    self?.setupBottomBar(for: currentPage)
                }
            }
        }
        
        setupHeader(for: timePage)
        addPage(timePage)
    }

    func setup(for time: Time) {
        model = CreateReviewModel(id: "1", time: time)
        currentPage?.setup(for: model)
        header.setup(for: time)
        setupBottomBar(for: currentPage!)
    }
    
    // MARK: Setup
    
    private func addPage(_ page: ReviewPage) {
        container.subviews.forEach { $0.removeFromSuperview() }
        container.addSubview(page.view)
        page.view.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        page.view.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        page.view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        page.view.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor).isActive = true
        page.view.layoutIfNeeded()
    }
    
    private func move(from: ReviewPage, to: ReviewPage, fromLeft: Bool) {
        
        setupHeader(for: to)
        setupBottomBar(for: to)
        to.setup(for: model)
        
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.subtype = fromLeft ? CATransitionSubtype.fromLeft : CATransitionSubtype.fromRight
        addPage(to)
        scrollView.layer.add(transition, forKey: "push")
    }
    
    private func setupBottomBar(for page: ReviewPage) {
        
        if page == submittedPage {
            bottomBar.setupForDismiss()
        } else if page == timePage {
            if model.timeRate != nil {
                bottomBar.setupForNext()
            } else {
                bottomBar.setupForNone()
            }
        } else if page == userPage {
            if model.userRate != nil {
                bottomBar.setupForBackAndNext()
            } else {
                bottomBar.setupForBack()
            }
        } else if page == tagsPage {
            if let tags = model.userTags, tags.count > 0 {
                bottomBar.setupForBackAndNext()
            } else {
                bottomBar.setupForBack()
            }
        } else if page == durationPage {
            if model.duration != nil {
                bottomBar.setupForBackAndNext()
            } else {
                bottomBar.setupForBack()
            }
        } else if page == commentPage {
            if let comment = model.comment, comment.count > 0 {
                bottomBar.setupForBackAndSubmit(true)
            } else {
                bottomBar.setupForBackAndSubmit(false)
            }
        }
    }
    
    private func setupHeader(for page: ReviewPage) {
        guard let step = pages.firstIndex(of: page) else { return }
        if step >= pages.count - 1 {
            header.setupForSubmitted()
        } else {
            header.setupStep(step+1, of: pages.count - 1)
        }
    }
    
    // MARK: - keyboard
    
    @objc private func keyboardUp() {
        if currentPage is ReviewCommentPage {
            UIView.animate(withDuration: 0.3) {
                self.headerHeight.constant = 60
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    @objc private func keyboardDown() {
        if currentPage is ReviewCommentPage {
            UIView.animate(withDuration: 0.3) {
                self.headerHeight.constant = 195
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - bottom bar
    
    private func back() {
        guard let page = currentPage else { return }
        
        if currentPage == submittedPage {
            closeTap?()
            return
        }
        
        guard let step = pages.firstIndex(of: page) else { return }
        
        if step > 0 {
            move(from: page, to: pages[step - 1], fromLeft: true)
        }
    }
    
    private func next() {
        guard let page = currentPage else { return }
        guard let step = pages.firstIndex(of: page) else { return }
        
        if step < pages.count - 1  {
            move(from: page, to: pages[step + 1], fromLeft: false)
        }
    }
    
    private func submit() {
        
        bottomBar.setupForBackAndNext(loading: true)
        
        TimesService.shared.sendTimeReview(timeId: model.time.id, review: model.review()) { [weak self] (success, errorMsg) in
            
            DispatchQueue.main.async {
                self?.bottomBar.setupForBackAndNext(loading: true)
                if success {
                    self?.next()
                } else {
                    self?.errorAlert(text: errorMsg ?? "Unknown error")
                }
            }
        }
    }

}
