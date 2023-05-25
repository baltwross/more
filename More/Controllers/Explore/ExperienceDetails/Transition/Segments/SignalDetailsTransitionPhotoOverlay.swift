//
//  SignalDetailsTransitionPhotoView.swift
//  More
//
//  Created by Luko Gjenero on 18/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class SignalDetailsTransitionPhotoOverlay: LoadableView {

    private static let gradientHeight: CGFloat = 167
    
    @IBOutlet private weak var page: UIPageControl!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var status: ExperienceStatusView!

    private let gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.whiteTwo.cgColor,
                        UIColor.whiteTwo.withAlphaComponent(0).cgColor]
        layer.locations = [0,  1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    override func setupNib() {
        super.setupNib()
        gradientView.layer.addSublayer(gradient)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = CGRect(x: 0, y: bounds.height - SignalDetailsTransitionPhotoOverlay.gradientHeight, width: bounds.width, height: SignalDetailsTransitionPhotoOverlay.gradientHeight)
    }
    
    func setup(experience: Experience) {
        page.numberOfPages = experience.images.count
        page.isHidden = experience.images.count <= 1
        status.setup(for: experience)
    }
}
