//
//  StarsView.swift
//  More
//
//  Created by Luko Gjenero on 09/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class StarsView: LoadableView {

    @IBOutlet private weak var star1: UIImageView!
    @IBOutlet private weak var star2: UIImageView!
    @IBOutlet private weak var star3: UIImageView!
    @IBOutlet private weak var star4: UIImageView!
    @IBOutlet private weak var star5: UIImageView!
    @IBOutlet private weak var paddingWidth: NSLayoutConstraint!
    
    var noStar: UIImage? = UIImage(named: "no_star") {
        didSet {
            refresh()
        }
    }
    var halfStar: UIImage? = UIImage(named: "half_star") {
        didSet {
            refresh()
        }
    }
    var fullStar: UIImage? = UIImage(named: "full_star") {
        didSet {
            refresh()
        }
    }
    
    var rateSelected: ((_ rate: CGFloat)->())?
    
    override func setupNib() {
        super.setupNib()
        
        for (idx, star) in stars.enumerated() {
            star.tag = idx
            star.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(starTap(sender:))))
        }
    }
    
    @IBInspectable var canSelect: Bool = false {
        didSet {
            for star in stars {
                star.isUserInteractionEnabled = canSelect
            }
        }
    }
    
    @objc func starTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let idx = sender.view?.tag {
                rate = CGFloat(idx + 1)
                rateSelected?(rate)
            }
        }
    }
    
    private var stars: [UIImageView] {
        return [star1, star2, star3, star4, star5]
    }
    
    @IBInspectable var rate: CGFloat = 0 {
        didSet {
            refresh()
        }
    }
    
    @IBInspectable var padding: CGFloat {
        get {
            return paddingWidth?.constant ?? 0
        }
        set {
            paddingWidth.constant = newValue
            setNeedsLayout()
        }
    }
    
    private func refresh() {
        let roundedRate = round(rate * 2) / 2
        for (idx, star) in stars.enumerated() {
            if Int(floor(roundedRate)) > idx {
                star.image = fullStar
            } else if Int(ceil(roundedRate)) > idx {
                star.image = halfStar
            } else {
                star.image = noStar
            }
        }
    }

}
