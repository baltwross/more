//
//  CreateSignalScheduleViewController.swift
//  More
//
//  Created by Luko Gjenero on 07/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalScheduleViewController: UIViewController {
    
    @IBOutlet private weak var selectorContainer: UIView!
    @IBOutlet private weak var selector: CreateSignalScheduleSelectorView!
    
    @IBOutlet private weak var scheduleContainer: UIView!
    @IBOutlet private weak var schedule: CreateSignalScheduleSetupView!
    
    @IBOutlet private weak var timeboxContainer: UIView!
    @IBOutlet private weak var timebox: CreateSignalScheduleTimeboxView!
    
    @IBOutlet private weak var startStopContainer: UIView!
    @IBOutlet private weak var startStop: CreateSignalScheduleStartStopView!
    
    private var data: ExperienceSchedule? = nil
    
    var back: (()->())?
    var selected: ((_ schedule: ExperienceSchedule?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.enableShadow(color: .black)
        
        selectorContainer.layer.cornerRadius = 12
        selectorContainer.layer.masksToBounds = true
        
        selector.close = { [weak self] in
            self?.back?()
        }
        
        selector.done = { [weak self] in
            self?.selected?(self?.data)
        }
        
        selector.anytime = { [weak self] in
            self?.data = nil
            self?.updateDoneButton()
        }
        
        selector.sometime = { [weak self] in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self?.setupScheduleLayout()
                    self?.view.layoutIfNeeded()
            })
        }
        
        scheduleContainer.layer.cornerRadius = 12
        scheduleContainer.layer.masksToBounds = true
        
        schedule.backTap = { [weak self] in
            UIView.animate(
            withDuration: 0.3,
            animations: {
                self?.setupSelectorLayout()
                self?.view.layoutIfNeeded()
            })
        }
        
        schedule.doneTap = { [weak self] schedule in
            UIView.animate(
            withDuration: 0.3,
            animations: {
                self?.setupStartStopLayout()
                self?.view.layoutIfNeeded()
            })
        }
        
        schedule.hoursTap = { [weak self] days in
            self?.timebox.setup(for: days, start: nil, end: nil)
            UIView.animate(
            withDuration: 0.3,
            animations: {
                self?.setupTimeboxLayout()
                self?.view.layoutIfNeeded()
            })
        }
        
        timeboxContainer.layer.cornerRadius = 12
        timeboxContainer.layer.masksToBounds = true
        
        timebox.backTap = { [weak self] in
            UIView.animate(
            withDuration: 0.3,
            animations: {
                self?.setupScheduleLayout()
                self?.view.layoutIfNeeded()
            })
        }
        
        timebox.doneTap = { [weak self] (days, start, end) in
            self?.updateDays(days, start: start, end: end)
            if let data = self?.data {
                self?.schedule.setup(for: data)
            }
            UIView.animate(
            withDuration: 0.3,
            animations: {
                self?.setupScheduleLayout()
                self?.view.layoutIfNeeded()
            })
        }
        
        startStopContainer.layer.cornerRadius = 12
        startStopContainer.layer.masksToBounds = true
        
        startStop.back = { [weak self] in
            UIView.animate(
            withDuration: 0.3,
            animations: {
                self?.setupScheduleLayout()
                self?.view.layoutIfNeeded()
            })
        }
        
        startStop.done = { [weak self] (start, end) in
            self?.data = self?.data?.experienceScheduleWithStartEnd(start: start, end: end)
            self?.selected?(self?.data)
        }
        
        setupSelectorLayout()
    }
    
    func setup(schedule: ExperienceSchedule) {
        updateSchedule(schedule)
        selector.selection = .sometime
        updateDoneButton()
        setupScheduleLayout()
    }
    
    func setupForAnytime() {
        selector.selection = .anytime
        updateDoneButton()
    }
    
    // MARK: - actions
    
    private func updateSchedule(_ schedule: ExperienceSchedule) {
        self.data = schedule
        self.schedule.setup(for: schedule)
    }
    
    private func updateDoneButton() {
        switch selector.selection {
        case .anytime:
            selector.doneIsHidden = false
            
        case .sometime:
            selector.doneIsHidden = false
            
        default:
            selector.doneIsHidden = true
            
        }
    }
    
    private func updateDays(_ days: WeekdayPicker.Days, start: TimeInterval?, end: TimeInterval?) {
        var monday = data?.monday
        var tuesday = data?.tuesday
        var wednesday = data?.wednesday
        var thursday = data?.thursday
        var friday = data?.friday
        var saturday = data?.saturday
        var sunday = data?.sunday
        
        if let start = start, let end = end {
            if days.contains(.monday) {
                monday = ExperienceDaySchedule(start: start, end: end)
            }
            if days.contains(.tuesday) {
                tuesday = ExperienceDaySchedule(start: start, end: end)
            }
            if days.contains(.wednesday) {
                wednesday = ExperienceDaySchedule(start: start, end: end)
            }
            if days.contains(.thursday) {
                thursday = ExperienceDaySchedule(start: start, end: end)
            }
            if days.contains(.friday) {
                friday = ExperienceDaySchedule(start: start, end: end)
            }
            if days.contains(.saturday) {
                saturday = ExperienceDaySchedule(start: start, end: end)
            }
            if days.contains(.sunday) {
                sunday = ExperienceDaySchedule(start: start, end: end)
            }
        } else {
            if days.contains(.monday) {
                monday = nil
            }
            if days.contains(.tuesday) {
                tuesday = nil
            }
            if days.contains(.wednesday) {
                wednesday = nil
            }
            if days.contains(.thursday) {
                thursday = nil
            }
            if days.contains(.friday) {
                friday = nil
            }
            if days.contains(.saturday) {
                saturday = nil
            }
            if days.contains(.sunday) {
                sunday = nil
            }
        }
        
        if monday != nil || tuesday != nil || wednesday != nil || thursday != nil || friday != nil || saturday != nil || sunday != nil {
            data = ExperienceSchedule(start: data?.start, end: data?.end, monday: monday, tuesday: tuesday, wednesday: wednesday, thursday: thursday, friday: friday, saturday: saturday, sunday: sunday)
        } else {
            data = nil
        }
        
        schedule.setup(for: data)
    }
    
    // MARK: UI
    
    private func setupSelectorLayout() {
        selectorContainer.alpha = 1
        selectorContainer.layer.transform = CATransform3DIdentity
        
        scheduleContainer.alpha = 1
        scheduleContainer.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.height, 0)
        
        timeboxContainer.alpha = 1
        timeboxContainer.layer.transform = CATransform3DMakeTranslation(UIScreen.main.bounds.width, 0, 0)
        
        startStopContainer.alpha = 1
        startStopContainer.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.height, 0)
    }
    
    private func setupScheduleLayout() {
        selectorContainer.alpha = 1
        selectorContainer.layer.transform = CATransform3DMakeTranslation(0, 300, 0)
        
        scheduleContainer.alpha = 1
        scheduleContainer.layer.transform = CATransform3DIdentity
        
        timeboxContainer.alpha = 1
        timeboxContainer.layer.transform = CATransform3DMakeTranslation(UIScreen.main.bounds.width, 0, 0)
        
        startStopContainer.alpha = 1
        startStopContainer.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.height, 0)
    }
    
    private func setupTimeboxLayout() {
        selectorContainer.alpha = 1
        selectorContainer.layer.transform = CATransform3DMakeTranslation(0, 300, 0)
        
        scheduleContainer.alpha = 1
        scheduleContainer.layer.transform = CATransform3DIdentity
        
        timeboxContainer.alpha = 1
        timeboxContainer.layer.transform = CATransform3DIdentity
        
        startStopContainer.alpha = 1
        startStopContainer.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.height, 0)
    }
    
    private func setupStartStopLayout() {
        selectorContainer.alpha = 1
        selectorContainer.layer.transform = CATransform3DMakeTranslation(0, 300, 0)
        
        scheduleContainer.alpha = 1
        scheduleContainer.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.height, 0)
        
        timeboxContainer.alpha = 1
        timeboxContainer.layer.transform = CATransform3DMakeTranslation(UIScreen.main.bounds.width, 0, 0)
        
        startStopContainer.alpha = 1
        startStopContainer.layer.transform = CATransform3DIdentity
    }
}
