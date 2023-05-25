//
//  MoodCell.swift
//  More
//
//  Created by Luko Gjenero on 27/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Lottie

private let imageScale: CGFloat = 0.82608695652

class MoodCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    private weak var animation: LottieAnimationView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        image.layer.anchorPoint = CGPoint(x: 0.5, y: 0.47391304347)
    }
    
    func setup(for type: SignalType, selected: Bool) {
        
        if selected {
            label.font = UIFont(name: "Avenir-Black", size: 20) ?? UIFont.systemFont(ofSize: 20)
            label.textColor = Colors.moodSelectedTitle
            label.text = type.rawValue.uppercased()
            image.isHidden = false
            image.image = SignalType.image(for: type)
            
            label.layer.transform = CATransform3DIdentity
            image.layer.transform = CATransform3DIdentity
            
        } else {
            label.font = UIFont(name: "Gotham-Bold", size: 11) ?? UIFont.systemFont(ofSize: 11)
            label.textColor = Colors.moodNotSelectedTitle
            label.text = type.rawValue.capitalized
            image.isHidden = false
            image.image = SignalType.grayscaleImage(for: type)
            
            label.layer.transform = CATransform3DMakeTranslation(0, 10, 0)
            var imageTransform = CATransform3DMakeScale(imageScale, imageScale, 1)
            imageTransform = CATransform3DTranslate(imageTransform, 0, -6, 0)
            image.layer.transform = imageTransform
        }
    }
    
    private func addAnimationView(for type: SignalType) {
        animation?.removeFromSuperview()
        
        let view = SignalType.animation(for: type)!
        
        addSubview(view)
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 12).isActive = true
        setNeedsLayout()
        
        animation = view
    }

}
