//
//  SearchDestinationDoneCell.swift
//  More
//
//  Created by Luko Gjenero on 28/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class SearchDestinationDoneCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        layer.zPosition = 2
    }
}
