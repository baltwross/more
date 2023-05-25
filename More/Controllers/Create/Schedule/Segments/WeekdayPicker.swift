//
//  WeekdayPicker.swift
//  More
//
//  Created by Luko Gjenero on 07/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class WeekdayPicker: LoadableView {
    
    struct Days: OptionSet {
        let rawValue: Int
        
        static let monday = Days(rawValue: 1)
        static let tuesday = Days(rawValue: 1 << 1)
        static let wednesday = Days(rawValue: 1 << 2)
        static let thursday = Days(rawValue: 1 << 3)
        static let friday = Days(rawValue: 1 << 4)
        static let saturday = Days(rawValue: 1 << 5)
        static let sunday = Days(rawValue: 1 << 6)
        
        static let weekdays: Days = [.monday, .tuesday, .wednesday, .thursday, .friday]
        static let weekend: Days = [.saturday, .sunday]
        static let all: Days = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        
        var label: String {
            switch self {
            case .monday:
                return "monday"
            case .tuesday:
                return "tuesday"
            case .wednesday:
                return "wednesday"
            case .thursday:
                return "thursday"
            case .friday:
                return "friday"
            case .saturday:
                return "saturday"
            case .sunday:
                return "sunday"
            default:
                return ""
            }
        }
        
        static func fromDayOfWeek(_ dayOfWeek: Int) -> Days {
            return Days(rawValue: 1 << (dayOfWeek - 1))
        }
    }

    @IBOutlet private weak var monday: DayView!
    @IBOutlet private weak var tuesday: DayView!
    @IBOutlet private weak var wednesday: DayView!
    @IBOutlet private weak var thursday: DayView!
    @IBOutlet private weak var friday: DayView!
    @IBOutlet private weak var saturday: DayView!
    @IBOutlet private weak var sunday: DayView!
    
    var selection: Days {
        get {
            var selection: Days = []
            if monday.status == .selected {
                selection.insert(.monday)
            }
            if tuesday.status == .selected {
                selection.insert(.tuesday)
            }
            if wednesday.status == .selected {
                selection.insert(.wednesday)
            }
            if thursday.status == .selected {
                selection.insert(.thursday)
            }
            if friday.status == .selected {
                selection.insert(.friday)
            }
            if saturday.status == .selected {
                selection.insert(.saturday)
            }
            if sunday.status == .selected {
                selection.insert(.sunday)
            }
            return selection
        }
        set {
            if newValue.contains(.monday) {
                monday.status = .selected
            }
            if newValue.contains(.tuesday) {
                tuesday.status = .selected
            }
            if newValue.contains(.wednesday) {
                wednesday.status = .selected
            }
            if newValue.contains(.thursday) {
                thursday.status = .selected
            }
            if newValue.contains(.friday) {
                friday.status = .selected
            }
            if newValue.contains(.saturday) {
                saturday.status = .selected
            }
            if newValue.contains(.sunday) {
                sunday.status = .selected
            }
        }
    }
    
    var highlight: Days {
        get {
            var higlight: Days = []
            if monday.status == .highlighted {
                higlight.insert(.monday)
            }
            if tuesday.status == .highlighted {
                higlight.insert(.tuesday)
            }
            if wednesday.status == .highlighted {
                higlight.insert(.wednesday)
            }
            if thursday.status == .highlighted {
                higlight.insert(.thursday)
            }
            if friday.status == .highlighted {
                higlight.insert(.friday)
            }
            if saturday.status == .highlighted {
                higlight.insert(.saturday)
            }
            if sunday.status == .highlighted {
                higlight.insert(.sunday)
            }
            return higlight
        }
        set {
            if newValue.contains(.monday) {
                monday.status = .highlighted
            }
            if newValue.contains(.tuesday) {
                tuesday.status = .highlighted
            }
            if newValue.contains(.wednesday) {
                wednesday.status = .highlighted
            }
            if newValue.contains(.thursday) {
                thursday.status = .highlighted
            }
            if newValue.contains(.friday) {
                friday.status = .highlighted
            }
            if newValue.contains(.saturday) {
                saturday.status = .highlighted
            }
            if newValue.contains(.sunday) {
                sunday.status = .highlighted
            }
        }
    }
    
    var selectionChanged: ((_ selection: Days)->())?
    var highlightChanged: ((_ selection: Days)->())?
    
    var highlightOnTouch: Bool = true
    
    func reset() {
        monday.status = .none
        tuesday.status = .none
        wednesday.status = .none
        thursday.status = .none
        friday.status = .none
        saturday.status = .none
        sunday.status = .none
    }
    
    override func setupNib() {
        super.setupNib()
        
        monday.text = "M"
        monday.isUserInteractionEnabled = true
        monday.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dayTouch(sender:))))
        monday.tag = Days.monday.rawValue
        
        tuesday.text = "T"
        tuesday.isUserInteractionEnabled = true
        tuesday.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dayTouch(sender:))))
        tuesday.tag = Days.tuesday.rawValue
        
        wednesday.text = "W"
        wednesday.isUserInteractionEnabled = true
        wednesday.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dayTouch(sender:))))
        wednesday.tag = Days.wednesday.rawValue
        
        thursday.text = "T"
        thursday.isUserInteractionEnabled = true
        thursday.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dayTouch(sender:))))
        thursday.tag = Days.thursday.rawValue
        
        friday.text = "F"
        friday.isUserInteractionEnabled = true
        friday.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dayTouch(sender:))))
        friday.tag = Days.friday.rawValue
        
        saturday.text = "S"
        saturday.isUserInteractionEnabled = true
        saturday.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dayTouch(sender:))))
        saturday.tag = Days.saturday.rawValue
        
        sunday.text = "S"
        sunday.isUserInteractionEnabled = true
        sunday.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dayTouch(sender:))))
        sunday.tag = Days.sunday.rawValue
    }
    
    @objc private func dayTouch(sender: UITapGestureRecognizer) {

        guard let dayView = sender.view as? DayView else { return }
        
        var signalHighlight = false
        var signalSelection = false
                
        if highlightOnTouch {
            if dayView.status == .selected {
                signalSelection = true
            }
            signalHighlight = true
            if dayView.status == .highlighted {
                dayView.status = .none
            } else {
                dayView.status = .highlighted
            }
        } else {
            if dayView.status == .highlighted {
                signalHighlight = true
            }
            signalSelection = true
            if dayView.status == .selected {
                dayView.status = .none
            } else {
                dayView.status = .selected
            }
        }
        if signalHighlight {
            highlightChanged?(highlight)
        }
        if signalSelection {
            selectionChanged?(selection)
        }
    }

}
