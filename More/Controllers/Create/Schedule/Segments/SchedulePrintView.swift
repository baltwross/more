//
//  SchedulePrintView.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let cellIdentifier = "Cell"

@IBDesignable
class SchedulePrintView: UITableView, UITableViewDelegate, UITableViewDataSource {

    private var rows: [ExperienceDaySchedule?] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    private func setup() {
        
        contentInsetAdjustmentBehavior = .never
        insetsContentViewsToSafeArea = false
        estimatedRowHeight = 50
        rowHeight = 50
        estimatedSectionFooterHeight = 0
        estimatedSectionHeaderHeight = 0
        tableFooterView = UIView()
        separatorColor = .clear
        separatorStyle = .none
        
        register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        register(Cell.self, forCellReuseIdentifier: cellIdentifier)
        
        dataSource = self
        delegate = self
    }
    
    func setup(for schedule: ExperienceSchedule?) {
    
        var rows: [ExperienceDaySchedule?] = []
        if let schedule = schedule {
            rows.append(schedule.monday)
            rows.append(schedule.tuesday)
            rows.append(schedule.wednesday)
            rows.append(schedule.thursday)
            rows.append(schedule.friday)
            rows.append(schedule.saturday)
            rows.append(schedule.sunday)
        }
        
        var deletedIndexes: [IndexPath] = []
        for idx in 0..<self.rows.count {
            deletedIndexes.append(IndexPath(row: idx, section: 0))
        }
        
        var insertedIndexes: [IndexPath] = []
        for idx in 0..<rows.count {
            insertedIndexes.append(IndexPath(row: idx, section: 0))
        }
        
        self.rows = rows
        beginUpdates()
        if deletedIndexes.count > 0 {
            deleteRows(at: deletedIndexes, with: .fade)
        }
        if insertedIndexes.count > 0 {
            insertRows(at: insertedIndexes, with: .fade)
        }
        endUpdates()
    }
    
    // MARK: - tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < rows.count,
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell {
            
            cell.setup(for: rows[indexPath.row], day: WeekdayPicker.Days.fromDayOfWeek(indexPath.row + 1))
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: Cell
    
    private class Cell: UITableViewCell {
        
        private let dayLabel: UILabel = {
            let day = UILabel()
            day.translatesAutoresizingMaskIntoConstraints = false
            day.backgroundColor = .clear
            day.textColor = .lightPeriwinkle
            day.font = UIFont(name: "Gotham-Medium", size: 15)
            return day
        }()
        
        private let timeLabel: UILabel = {
            let time = UILabel()
            time.translatesAutoresizingMaskIntoConstraints = false
            time.backgroundColor = .clear
            time.textColor = .lightPeriwinkle
            time.font = UIFont(name: "Avenir-Medium", size: 15)
            return time
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }

        
        private func setup() {
            contentView.addSubview(dayLabel)
            contentView.addSubview(timeLabel)
            
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50).isActive = true
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50).isActive = true
            
            contentView.setNeedsLayout()
            
            selectionStyle = .none
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        func setup(for daySchedule: ExperienceDaySchedule?, day: WeekdayPicker.Days) {
            if let daySchedule = daySchedule {
                dayLabel.textColor = .charcoalGrey
                timeLabel.textColor = .blueGrey
                
                let start = Date().startOfDay.addingTimeInterval(daySchedule.start)
                let end = Date().startOfDay.addingTimeInterval(daySchedule.end)
                let df = DateFormatter()
                df.dateFormat = "h:mma"
                
                timeLabel.text = "\(df.string(from: start)) - \(df.string(from: end))"
            } else {
                dayLabel.textColor = .lightPeriwinkle
                timeLabel.textColor = .lightPeriwinkle
                timeLabel.text = "None"
            }
            dayLabel.text = day.label.capitalized
        }
    }

}
