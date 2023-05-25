//
//  ReviewUserTagsPage.swift
//  More
//
//  Created by Luko Gjenero on 24/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewUserTagsPage: ReviewPage {

    @IBOutlet private weak var header : ReviewSegmentHeader!
    @IBOutlet private weak var adventurous : ReviewUserTagView!
    @IBOutlet private weak var open : ReviewUserTagView!
    @IBOutlet private weak var curious : ReviewUserTagView!
    @IBOutlet private weak var creative : ReviewUserTagView!
    @IBOutlet private weak var respectful : ReviewUserTagView!
    @IBOutlet private weak var funny : ReviewUserTagView!
    
    private var model: CreateReviewModel? = nil
    
    private lazy var tags: [ReviewUserTagView] = [adventurous, open, curious, creative, respectful, funny]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        var allTags = Review.Tag.all
        for (idx, view) in tags.enumerated() {
            view.tagType = allTags[idx]
            view.tag = idx
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tagTap(sender:))))
        }
    }

    @objc private func tagTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let tagView = sender.view as? ReviewUserTagView {
                let tag = Review.Tag.all[tagView.tag]
                if model?.userTags == nil {
                    model?.userTags = []
                }
                if model?.userTags?.contains(tag) == true {
                    model?.userTags?.removeAll(where: { $0 == tag })
                    tagView.setupSelected(false)
                } else {
                    model?.userTags?.append(tag)
                    tagView.setupSelected(true)
                }
                dataChanged?()
            }
        }
    }
    
    override func setup(for model: CreateReviewModel) {
        self.model = model
        let title = "Describe \(model.time.otherPerson().name)"
        let subtitle = "More is for passionate people eager to make more of life. Check all that apply to \(model.time.otherPerson().name)."
        header.setup(title: title, subtitle: subtitle)
        
        if let tags = model.userTags, tags.count > 0 {
            for view in self.tags {
                view.setupSelected(tags.contains(view.tagType))
            }
        }
    }
}
