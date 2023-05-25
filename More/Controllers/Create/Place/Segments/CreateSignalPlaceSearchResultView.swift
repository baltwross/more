//
//  CreateSignalPlaceSearchResultView.swift
//  More
//
//  Created by Luko Gjenero on 13/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let cellIdentifier = "Cell"

@IBDesignable
class CreateSignalPlaceSearchResultView: UITableView, UITableViewDelegate, UITableViewDataSource {

    private var rows: [PlacesSearchService.PlaceData] = []
    
    var selected: ((_ place: PlacesSearchService.PlaceData)->())?
    
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
        estimatedRowHeight = 80
        rowHeight = 80
        estimatedSectionFooterHeight = 0
        estimatedSectionHeaderHeight = 0
        tableFooterView = UIView()
        
        register(UITableViewCell.self, forCellReuseIdentifier: "Dummy")
        register(Cell.self, forCellReuseIdentifier: cellIdentifier)
        
        dataSource = self
        delegate = self
    }
    
    func setup(for rows: [PlacesSearchService.PlaceData]) {
        
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
            
            cell.setup(for: rows[indexPath.row])
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "Dummy", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected?(rows[indexPath.row])
    }
    
    // MARK: Cell
    
    private class Cell: UITableViewCell {
        
        private let content: CreateSignalPlaceSearchItem = {
            let content = CreateSignalPlaceSearchItem()
            content.translatesAutoresizingMaskIntoConstraints = false
            content.backgroundColor = .clear
            return content
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }

        
        private func setup() {
            contentView.addSubview(content)
            
            content.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            
            contentView.setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        func setup(for place: PlacesSearchService.PlaceData) {
            content.setup(for: place)
        }
    }

}
