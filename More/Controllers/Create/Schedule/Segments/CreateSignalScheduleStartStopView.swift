//
//  CreateSignalScheduleStartStopView.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalScheduleStartStopView: LoadableView {

    @IBOutlet fileprivate weak var topBar: CreateSignalScheduleStartStopTopBar!
    
    @IBOutlet fileprivate weak var startNow: CreateSignalScheduleNowItem!
    @IBOutlet fileprivate weak var startDate: CreateSignalScheduleOnADateItem!
    @IBOutlet fileprivate weak var startPickerContainer: UIView!
    @IBOutlet fileprivate weak var startPickerContainerHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var startPicker: UIDatePicker!
    
    @IBOutlet fileprivate weak var endNever: CreateSignalScheduleNeverItem!
    @IBOutlet fileprivate weak var endDate: CreateSignalScheduleOnADateItem!
    @IBOutlet fileprivate weak var endPickerContainer: UIView!
    @IBOutlet fileprivate weak var endPickerContainerHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var endPicker: UIDatePicker!
    
    @IBOutlet fileprivate var scrollViewHeight: NSLayoutConstraint!
    
    private var start: Date? = nil
    private var end: Date? = nil
    
    var back: (()->())?
    var done: ((_ start: Date?, _ end: Date?)->())?
    
    override func setupNib() {
        super.setupNib()
        
        topBar.backTap = { [weak self] in
            self?.back?()
        }
        
        topBar.doneTap = { [weak self] in
            self?.done?(self?.start, self?.end)
        }
        
        startNow.tap = { [weak self] in
            self?.start = nil
            self?.updateUI(animated: true)
        }
        
        startDate.tap = { [weak self] in
            self?.start = Date()
            self?.updateUI(animated: true)
        }
        
        startPicker.addTarget(self, action: #selector(startDateChanged(picker:)), for: .valueChanged)
        
        endNever.tap = { [weak self] in
            self?.end = nil
            self?.updateUI(animated: true)
        }
        
        endDate.tap = { [weak self] in
            self?.end = Date()
            self?.updateUI(animated: true)
        }
        
        endPicker.addTarget(self, action: #selector(endDateChanged(picker:)), for: .valueChanged)
        
        updateUI()
    }
    
    
    @objc private  func startDateChanged(picker: UIDatePicker) {
        start = picker.date
    }
    
    @objc private  func endDateChanged(picker: UIDatePicker) {
        end = picker.date
    }
    
    func setup(for schedule: ExperienceSchedule) {
        start = schedule.start
        end = schedule.end
        updateUI()
    }
    
    // MARK: - UI
    
    private func updateUI(animated: Bool = false) {
        if animated {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.updateLayout()
                    self.layoutIfNeeded()
                })
        } else {
            updateLayout()
        }
    }
    
    private func updateLayout() {
        
        var startExpanded = false
        var endExpanded = false
        
        if let start = start {
            startNow.isSelected = false
            startDate.isSelected = true
            startPicker.setDate(start, animated: false)
            startPickerContainerHeight.constant = 217
            startExpanded = true
        } else {
            startNow.isSelected = true
            startDate.isSelected = false
            startPickerContainerHeight.constant = 0
        }
        if let end = end {
            endNever.isSelected = false
            endDate.isSelected = true
            endPicker.setDate(end, animated: false)
            endPickerContainerHeight.constant = 217
            endExpanded = true
        } else {
            endNever.isSelected = true
            endDate.isSelected = false
            endPickerContainerHeight.constant = 0
        }
        
        if startExpanded && endExpanded {
            scrollViewHeight.isActive = false
        } else {
            scrollViewHeight.constant = 388 + (startExpanded || endExpanded ? 217 : 0)
            scrollViewHeight.isActive = true
        }
    }
}
