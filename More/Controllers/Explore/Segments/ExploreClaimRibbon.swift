//
//  ExploreClaimRibbon.swift
//  More
//
//  Created by Luko Gjenero on 15/01/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExploreClaimRibbon: LoadableView {

    enum RibbonType {
        case longClaim, shortClaim, longCurated, shortCurated
    }
    
    @IBOutlet private weak var ribbon: UIImageView!
    @IBOutlet private weak var label: UILabel!
    
    var type: RibbonType = .shortClaim {
        didSet{
            switch type {
            case .shortClaim:
                ribbon.image = UIImage(named: "claim-ribbon-short")
                label.textColor = .white
                label.font = UIFont(name: "Gotham-Black", size: 10) ?? UIFont.systemFont(ofSize: 10)
                label.text = "SUGGESTED"
            case .longClaim:
                ribbon.image = UIImage(named: "claim-ribbon-long")
                label.textColor = .white
                label.font = UIFont(name: "Gotham-Black", size: 10) ?? UIFont.systemFont(ofSize: 10)
                label.text = "SUGGESTED"
            case .shortCurated:
                ribbon.image = UIImage(named: "curated-ribbon-short")
                label.textColor = .white
                label.font = UIFont(name: "Gotham-Black", size: 10) ?? UIFont.systemFont(ofSize: 10)
                label.text = "CURATED"
            case .longCurated:
                ribbon.image = UIImage(named: "curated-ribbon-long")
                label.textColor = .white
                label.font = UIFont(name: "Gotham-Black", size: 10) ?? UIFont.systemFont(ofSize: 10)
                label.text = "CURATED"
                
            }
        }
    }

}
