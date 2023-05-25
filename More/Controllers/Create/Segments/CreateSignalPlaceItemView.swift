//
//  CreateSignalPlaceItemView.swift
//  More
//
//  Created by Luko Gjenero on 07/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class CreateSignalPlaceItemView: LoadableView {

    @IBOutlet fileprivate weak var icon: UIButton!
    @IBOutlet fileprivate weak var title: UILabel!
    @IBOutlet fileprivate weak var subtitle: UILabel!
    
    override func setupNib() {
        super.setupNib()
        
        icon.setImage(UIImage(named: "create-pin-off"), for: .normal)
    }
    
    func setup(for place: PlacesSearchService.PlaceData) {
        title.text = place.name
        subtitle.text = place.address
    }

}
