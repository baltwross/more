//
//  ReviewDurationPage.swift
//  More
//
//  Created by Luko Gjenero on 24/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ReviewDurationPage: ReviewPage {

    @IBOutlet private weak var header : ReviewSegmentHeader!
    @IBOutlet private weak var underAnHour : ReviewDurationView!
    @IBOutlet private weak var oneToTwoHours : ReviewDurationView!
    @IBOutlet private weak var threeToFourHours : ReviewDurationView!
    @IBOutlet private weak var overFourHours : ReviewDurationView!
    
    private var model: CreateReviewModel? = nil
    
    private lazy var durations: [ReviewDurationView] = [underAnHour, oneToTwoHours, threeToFourHours, overFourHours]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        var allDurations = Review.Duration.all
        for (idx, view) in durations.enumerated() {
            view.duration = allDurations[idx]
            view.tag = idx
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(durationTap(sender:))))
        }
    }
    
    @objc private func durationTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let durationView = sender.view as? ReviewDurationView {
                let duration = Review.Duration.all[durationView.tag]
                model?.duration = duration
                updateSelection()
                dataChanged?()
            }
        }
    }
    
    override func setup(for model: CreateReviewModel) {
        self.model = model
        let title = "Duration"
        let subtitle = "How long did you hang out for?"
        header.setup(title: title, subtitle: subtitle)
        updateSelection()
    }

    private func updateSelection() {
        let duration = model?.duration
        for view in durations {
            view.setupSelected(view.duration == duration)
        }
    }

}
