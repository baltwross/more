//
//  SearchDestinationItemCell.swift
//  More
//
//  Created by Luko Gjenero on 28/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class SearchDestinationItemCell: UITableViewCell {

    @IBOutlet private weak var journeyItem: SignalJourneyItemView!
    @IBOutlet private weak var tick: UIButton!
    
    private var enableShadow: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        layer.zPosition = 1
    }
    
    func setupSomewhere(for model: CreateExperienceViewModel) {
        journeyItem.type = SignalJourneyItemView.ItemType.somewhere.rawValue
        journeyItem.setup(for: model)
        tick.isHidden = false
        tick.isSelected = model.somewhere
        layer.zPosition = 1
        selectionStyle = .none
        enableShadow = true
        setNeedsLayout()
    }
    
    func setupAdd(for model: CreateExperienceViewModel) {
        journeyItem.type = SignalJourneyItemView.ItemType.add.rawValue
        journeyItem.setup(for: model)
        tick.isHidden = true
        layer.zPosition = 2
        selectionStyle = .none
        enableShadow = false
        setNeedsLayout()
    }
    
    func setupDestination(for model: CreateExperienceViewModel) {
        journeyItem.type = SignalJourneyItemView.ItemType.destination.rawValue
        journeyItem.setup(for: model)
        tick.isHidden = false
        tick.isSelected = model.destination != nil
        layer.zPosition = 2
        selectionStyle = .none
        enableShadow = false
        setNeedsLayout()
    }
    
    func setupPlace(for place: PlacesSearchService.PlaceData) {
        journeyItem.type = SignalJourneyItemView.ItemType.add.rawValue
        journeyItem.setup(for: place)
        tick.isHidden = true
        layer.zPosition = 2
        selectionStyle = .default
        enableShadow = false
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if enableShadow {
            let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 40, width: contentView.bounds.width, height: contentView.bounds.height - 40))
            contentView.enableShadow(color: .black, path: shadowPath.cgPath)
        } else {
            contentView.layer.shadowColor = UIColor.clear.cgColor
        }
    }
    
}
