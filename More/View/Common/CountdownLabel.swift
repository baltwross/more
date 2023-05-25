//
//  CountdownLabel.swift
//  More
//
//  Created by Luko Gjenero on 14/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class CountdownLabel: UILabel {

    var refreshIterval: TimeInterval = 1 {
        didSet {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: refreshIterval, target: self, selector: #selector(timerTick(_:)), userInfo: nil, repeats: true)
        }
    }
    var isHideWhenFinished = false
    
    private(set) var timer: Timer?
    
    @IBInspectable var timeColor: UIColor? = nil
    @IBInspectable var timeFont: UIFont? = nil
    
    private var dateFromatter: DateFormatter?
    private var limitDate: Date = Date(timeIntervalSinceNow: -1)
   
    private var labels = [String]()
    
    func countdown(to date: Date) {
        limitDate = date
        let refreshItervalValue = refreshIterval
        refreshIterval = refreshItervalValue
        refreshLabel()
    }
    
    func setDateFormat(_ dateFormat: String) {
        var lastLocation: Int = 0
        var loc1 = NSRange(location: 0, length: 0)
        var loc2 = NSRange(location: 0, length: 0)
        let quotes = CharacterSet(charactersIn: "'")
        var labels = [String]()
        while loc1.location != NSNotFound && loc2.location != NSNotFound && lastLocation <
            dateFormat.count {
                
            // search for a pair of qoutes
            loc1 = (dateFormat as NSString).rangeOfCharacter(from: quotes, options: [], range: NSRange(location: lastLocation, length: dateFormat.count - lastLocation))
            if loc1.location != NSNotFound && loc1.location < dateFormat.count - 1 {
                lastLocation = Int(loc1.location) + 1
                loc2 = (dateFormat as NSString).rangeOfCharacter(from: quotes, options: [], range: NSRange(location: lastLocation, length: dateFormat.count - lastLocation))
                if loc2.location != NSNotFound {
                    lastLocation = Int(loc2.location) + 1
                    labels.append((dateFormat as NSString).substring(with: NSRange(location: loc1.location + 1, length: loc2.location - loc1.location - 1)))
                }
            } else {
                loc2.location = NSNotFound
            }
        }
        
        self.labels = labels
        dateFromatter?.dateFormat = dateFormat
        refreshLabel()
    }
    
    // MARK: - init/dealloc
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func setup()  {
        dateFromatter = DateFormatter()
        dateFromatter?.dateFormat = "H:mm:ss"
        dateFromatter?.timeZone = TimeZone(secondsFromGMT: 0)
        refreshIterval = 0.5 as TimeInterval
    }
    
    func makeStatic() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        makeStatic()
        text = ""
    }
    
    // MARK: - public methods
    // MARK: - timer
    
    @objc func timerTick(_ timer: Timer) {
        if Date().compare(limitDate) == .orderedDescending {
            self.timer?.invalidate()
            self.timer = nil
        }
        refreshLabel()
    }
    
    func refreshLabel() {
        let difference: TimeInterval = limitDate.timeIntervalSince1970 - Date().timeIntervalSince1970
        var text: String
        if (dateFromatter?.dateFormat == "HHH") {
            text = "\(Int(difference / (60 * 60)))"
        } else {
            let diffDate = Date(timeIntervalSince1970: difference)
            text = (difference >= 0 ? dateFromatter?.string(from: diffDate) : dateFromatter?.string(from: Date(timeIntervalSince1970: 0))) ?? ""
        }
        if timeColor != nil && timeFont != nil && font != nil && textColor != nil {
            let timeText = NSMutableAttributedString(string: text, attributes: [.foregroundColor: timeColor!, .font: timeFont!])
            let labelAttributes :[NSAttributedString.Key:Any] = [.foregroundColor: textColor!, .font: font!]
            for label: String in labels {
                let range: NSRange = (text as NSString).range(of: label)
                if range.location != NSNotFound {
                    timeText.setAttributes(labelAttributes, range: range)
                }
            }
            attributedText = timeText
        } else {
            self.text = text
        }
    }
}

