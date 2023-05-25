//
//  CreateSignalScheduleSetupView.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalScheduleSetupView: LoadableView {

    @IBOutlet private weak var topBar: CreateSignalScheduleSetupTopBar!
    @IBOutlet private weak var daysLabel: UILabel!
    @IBOutlet private weak var dayPicker: WeekdayPicker!
    @IBOutlet private weak var setHoursButton: UIButton!
    @IBOutlet private weak var scheduleLabel: UILabel!
    @IBOutlet private weak var schedule: SchedulePrintView!
    
    // wtf fix for some weird shit in ios13
    @IBOutlet private weak var scheduleHeight: NSLayoutConstraint!
    
    private var data: ExperienceSchedule? = nil
    
    var backTap: (()->())?
    var doneTap: ((_ schedule: ExperienceSchedule?)->())?
    var hoursTap: ((_ days: WeekdayPicker.Days)->())?
    
    override func setupNib() {
        super.setupNib()
        
        topBar.doneIsEnabled = false
        setHoursButton.isEnabled = false
        
        topBar.backTap = { [weak self] in
            self?.backTap?()
        }
        
        topBar.doneTap = { [weak self] in
            self?.doneTap?(self?.data)
        }
        
        dayPicker.highlightOnTouch = true
        dayPicker.highlightChanged = { [weak self] (_) in
            self?.setupDaysLabel()
            self?.setupHoursButton()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let superview = superview {
            scheduleHeight.constant = superview.bounds.height - 327 - superview.safeAreaInsets.bottom 
        }
    }
    
    @IBAction private func setHoursTouch(_ sender: Any) {
        hoursTap?(dayPicker.highlight)
    }
    
    func setup(for schedule: ExperienceSchedule?) {
        data = schedule

        setupDays()
        setupDaysLabel()
        setupDoneButton()
        setupSchedule()
        setupHoursButton()
    }
    
    // MARK: - UI

    private func setupDoneButton() {
        topBar.doneIsEnabled = data != nil
    }
    
    private func setupDaysLabel() {
        guard !dayPicker.highlight.isEmpty else {
            daysLabel.text = "DAYS OF THE WEEK"
            return
        }
        
        var days: [String] = []
        if dayPicker.highlight.contains(.monday) {
            days.append("MON")
        }
        if dayPicker.highlight.contains(.tuesday) {
            days.append("TUE")
        }
        if dayPicker.highlight.contains(.wednesday) {
            days.append("WED")
        }
        if dayPicker.highlight.contains(.thursday) {
            days.append("THU")
        }
        if dayPicker.highlight.contains(.friday) {
            days.append("FRI")
        }
        if dayPicker.highlight.contains(.saturday) {
            days.append("SAT")
        }
        if dayPicker.highlight.contains(.sunday) {
            days.append("SUN")
        }
        daysLabel.text = days.joined(separator: ", ")
    }
    
    private func setupDays() {
        dayPicker.reset()
        
        var days: WeekdayPicker.Days = []
        if data?.monday != nil {
            days.insert(.monday)
        }
        if data?.tuesday != nil {
            days.insert(.tuesday)
        }
        if data?.wednesday != nil {
            days.insert(.wednesday)
        }
        if data?.thursday != nil {
            days.insert(.thursday)
        }
        if data?.friday != nil {
            days.insert(.friday)
        }
        if data?.saturday != nil {
            days.insert(.saturday)
        }
        if data?.sunday != nil {
            days.insert(.sunday)
        }
        dayPicker.selection = days
    }
    
    private func setupHoursButton() {
        setHoursButton.isEnabled = !dayPicker.highlight.isEmpty
    }
    
    private func setupSchedule() {
        if data != nil {
            scheduleLabel.text = "Schedule"
        } else {
            scheduleLabel.text = "No schedule set."
        }
        schedule.setup(for: data)
    }
    
}
