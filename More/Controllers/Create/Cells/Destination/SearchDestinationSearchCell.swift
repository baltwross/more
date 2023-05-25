//
//  SearchDestinationSearchCell.swift
//  More
//
//  Created by Luko Gjenero on 28/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class SearchDestinationSearchCell: UITableViewCell {

    @IBOutlet private weak var searchBar: SearchBar!
    
    var searchUpdated: ((_ searchString: String?)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        searchBar.textUpdated = { [weak self] (searchString) in
            self?.searchUpdated?(searchString)
        }
        searchBar.searchTap = { [weak self] (searchString) in
            self?.searchBar.hideKeyboard()
            self?.searchUpdated?(searchString)
        }
        
        layer.zPosition = 0
    }
    
    func showKeyboard() {
        searchBar.showKeyboard()
    }
    
    func hideKeyboard() {
        searchBar.hideKeyboard()
    }
    
}
