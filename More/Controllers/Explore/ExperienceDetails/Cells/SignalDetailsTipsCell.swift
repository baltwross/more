//
//  SignalDetailsTipsCell.swift
//  More
//
//  Created by Luko Gjenero on 29/09/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class SignalDetailsTipsCell: SignalDetailsBaseCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var tipsView: SignalTipsView!
    @IBOutlet private weak var tipsViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var addButtonWidth: NSLayoutConstraint!
    @IBOutlet private weak var emptyLabel: UILabel!
    
    private let gradient = CAGradientLayer()
    
    var add: (()->())?
    var upvoteTip: ((_ tip: ExperienceTip)->())?
    var downvoteTip: ((_ tip: ExperienceTip)->())?
    
    @IBAction private func addTouch(_ sender: Any) {
        add?()
    }
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        gradient.colors = [UIColor.whiteTwo.cgColor, UIColor.lightPeriwinkle.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.locations = [0.0, 1.0]
        gradient.frame = contentView.bounds
        contentView.layer.insertSublayer(gradient, at: 0)
        
        addButton.layer.cornerRadius = 15
        addButton.enableShadow(color: .black, path: UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 30, height: 30), cornerRadius: 15).cgPath)
        
        tipsView.contentInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 32)
        tipsView.upvoteTip = { [weak self] tip in
            self?.upvoteTip?(tip)
        }
        tipsView.downvoteTip = { [weak self] tip in
            self?.downvoteTip?(tip)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.frame = contentView.bounds
    }

    // MARK: - experience details view
    
    override class func isShowing(for experience: Experience) -> Bool {
        return true
    }
    
    override func setup(for experience: Experience) {
        if let tips = experience.tips, !tips.isEmpty {
            tipsView.isHidden = false
            tipsViewHeight.constant = 176
            addButtonWidth.constant = 30
            addButton.setImage(UIImage(named: "add-tip"), for: .normal)
            addButton.setTitle("", for: .normal)
            emptyLabel.isHidden = true
        } else {
            tipsView.isHidden = true
            tipsViewHeight.constant = 29
            addButtonWidth.constant = 90
            addButton.setImage(nil, for: .normal)
            addButton.setTitle("ADD TIP", for: .normal)
            emptyLabel.isHidden = false
        }
        
        tipsView.setup(for: experience)
    }
    
    // MARK: - experience preview
    
    override func setup(for model: CreateExperienceViewModel) {
        // nothing
    }
    
    override class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        return false
    }
    
}
