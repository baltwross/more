//
//  CreateSignalScheduleTimeboxView.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let startDefault: TimeInterval = 39600 // 11 AM
private let endDefault: TimeInterval = 61200 // 5 PM

class CreateSignalScheduleTimeboxView: LoadableView, TenClockDelegate {

    @IBOutlet private weak var topBar: CreateSignalScheduleTimeboxTopBar!
    @IBOutlet private weak var daysLabel: UILabel!
    @IBOutlet private weak var daysView: SelectedWeekdaysView!
    @IBOutlet private weak var startLabel: UILabel!
    @IBOutlet private weak var endLabel: UILabel!
    @IBOutlet private weak var clock: TenClock!
    
    // Layout outlets
    @IBOutlet private weak var clockLeading: NSLayoutConstraint!
    @IBOutlet private weak var clockTop: NSLayoutConstraint!
    @IBOutlet private weak var resetBottom: NSLayoutConstraint!
    @IBOutlet private weak var separatorTop: NSLayoutConstraint!
    
    private var days: WeekdayPicker.Days = []
    private var start: TimeInterval? = nil
    private var end: TimeInterval? = nil
    
    private var df = DateFormatter()
    
    var backTap: (()->())?
    var doneTap: ((_ days: WeekdayPicker.Days, _ start: TimeInterval?, _ end: TimeInterval?)->())?
    
    override func setupNib() {
        super.setupNib()
        
        topBar.doneIsEnabled = true
        
        topBar.backTap = { [weak self] in
            self?.backTap?()
        }
        
        topBar.doneTap = { [weak self] in
            self?.doneTap?(self?.days ?? [], self?.start, self?.end)
        }
        
        clock.delegate = self
        
        // Layout for smaller phones
        if UIScreen.main.bounds.height < 736 {
            clockLeading.constant = 16
            clockTop.constant = 100
            resetBottom.constant = 10
            separatorTop.constant = 150
        }
        
        setupUI()
    }
    
    @IBAction private func resetTouch(_ sender: Any) {
        start = nil
        end = nil
        setupUI()
    }
    
    func setup(for days: WeekdayPicker.Days, start: TimeInterval?, end: TimeInterval?) {
        
        self.days = days
        self.start = start
        self.end = end
        
        setupUI()
        if let start = start, let end = end {
            clock.startDate = Date().startOfDay.addingTimeInterval(start)
            clock.endDate = Date().startOfDay.addingTimeInterval(end)
        }
    }
    
    // MARK: - UI

    private func setupUI() {
        daysView.setup(for: days)
        update10Clock()
        updateTimes()
    }
    
    private func update10Clock() {
        if start == nil {
            clock.grayscale = true
            clock.startDate = Date().startOfDay.addingTimeInterval(startDefault)
            clock.endDate = Date().startOfDay.addingTimeInterval(endDefault)
            clock.update()
        } else {
            clock.grayscale = false
        }
    }
    
    private func updateTimes() {
        let start = self.start ?? startDefault
        
        let startDate = Date().startOfDay.addingTimeInterval(start)
        let startStr = NSMutableAttributedString()

        df.dateFormat = "hh:mm"
        var font = UIFont(name: "DIN-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32)
        var part = NSAttributedString(
            string: df.string(from: startDate),
            attributes: [NSAttributedString.Key.font : font])
        startStr.append(part)
        
        df.dateFormat = "a"
        
        font = UIFont(name: "DIN-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)
        part = NSAttributedString(
            string: df.string(from: startDate),
            attributes: [NSAttributedString.Key.font : font])
        startStr.append(part)
        
        startLabel.attributedText = startStr
        startLabel.alpha = self.start != nil ? 1 : 0.3
        
        
        let end = self.end ?? endDefault
        let endDate = Date().startOfDay.addingTimeInterval(end)
        let endStr = NSMutableAttributedString()

        df.dateFormat = "hh:mm"
        font = UIFont(name: "DIN-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32)
        part = NSAttributedString(
            string: df.string(from: endDate),
            attributes: [NSAttributedString.Key.font : font])
        endStr.append(part)
        
        df.dateFormat = "a"
        
        font = UIFont(name: "DIN-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18)
        part = NSAttributedString(
            string: df.string(from: endDate),
            attributes: [NSAttributedString.Key.font : font])
        endStr.append(part)
        
        endLabel.attributedText = endStr
        endLabel.alpha = self.end != nil ? 1 : 0.3
    }
    
    
    // MARK: 10Clock
    
    func timesUpdateStarted(_ clock: TenClock) {
        findViewController()?.isModalInPresentation = true
        findViewController()?.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
    }
    
    func timesUpdated(_ clock:TenClock, startDate:Date, endDate:Date) {
        let update = start == nil
        let today = Date().startOfDay
        start = startDate.timeIntervalSince(today)
        end = endDate.timeIntervalSince(today)
        while start! < 0 {
            start = start! + 86400
            end = end! + 86400
        }
        if update {
            update10Clock()
        }
        updateTimes()
    }
    
    func timesUpdateStopped(_ clock: TenClock, startDate: Date, endDate: Date) {
        findViewController()?.isModalInPresentation = false
        findViewController()?.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = true
    }
}
