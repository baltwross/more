//
//  SelectedWeekdaysView.swift
//  More
//
//  Created by Luko Gjenero on 14/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let cellIdentifier = "Cell"

class SelectedWeekdaysView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var days: WeekdayPicker.Days = []
    
    private var dayLabels: [String] {
        var days: [String] = []
        if self.days.contains(.monday) {
            days.append("M")
        }
        if self.days.contains(.tuesday) {
            days.append("T")
        }
        if self.days.contains(.wednesday) {
            days.append("W")
        }
        if self.days.contains(.thursday) {
            days.append("T")
        }
        if self.days.contains(.friday) {
            days.append("F")
        }
        if self.days.contains(.saturday) {
            days.append("S")
        }
        if self.days.contains(.sunday) {
            days.append("S")
        }
        return days
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        register(Cell.self, forCellWithReuseIdentifier: cellIdentifier)
        dataSource = self
        delegate = self
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.minimumInteritemSpacing = 15
            layout.itemSize = CGSize(width: 35, height: 35)
        }
    }
    
    func setup(for days: WeekdayPicker.Days) {
        self.days = days
        reloadData()
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item < dayLabels.count,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? Cell {
            cell.setup(for: dayLabels[indexPath.item])
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        private let dayView: DayView = {
            let day = DayView()
            day.translatesAutoresizingMaskIntoConstraints = false
            day.backgroundColor = .clear
            day.status = .selected
            return day
        }()
        
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(dayView)
            
            dayView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            dayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            dayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            dayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            
            contentView.setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for label: String) {
            dayView.text = label
        }
    }
    
}
