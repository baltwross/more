//
//  ExperienceDetailsTransitionView.swift
//  More
//
//  Created by Luko Gjenero on 15/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ExperienceDetailsTransitionView: LoadableView {

    @IBOutlet private weak var back: UIButton!
    @IBOutlet private weak var like: UIButton!
    @IBOutlet private weak var share: UIButton!
    @IBOutlet private weak var more: UIButton!
    @IBOutlet private weak var moreWidth: NSLayoutConstraint!
    @IBOutlet private weak var topFade: FadeView!
    
    @IBOutlet private weak var content: ExploreCollectionViewCellContent!
    @IBOutlet private weak var photoOverlay: SignalDetailsTransitionPhotoOverlay!
    @IBOutlet private weak var quote: SignalDetailsTransitionQuoteView!

    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var photoHeightConstraint: NSLayoutConstraint!
    
    private weak var overlayView: UIView?
    
    override func setupNib() {
        super.setupNib()
        
        back.layer.transform = CATransform3DMakeRotation(-CGFloat.pi * 0.5, 0, 0, 1)
        more.layer.transform = CATransform3DMakeRotation(-CGFloat.pi * 0.5, 0, 0, 1)
        
        topFade.orientation = .up
        topFade.color = UIColor.black.withAlphaComponent(0.5)
        
        share.alpha = 0
        like.alpha = 0.5
    }
    
    func setup(for experience: Experience, photo: UIImage?, overlay: UIImage? = nil) {
        
        // header
//        if experience.creator.isMe() {
//            more.isHidden = true
//            moreWidth.constant = 0
//        }
        
        ExperienceService.shared.haveLikedExperience(experienceId: experience.id) { [weak self] (liked, _) in
            self?.like.tintColor = liked == true ? .fireEngineRed : .whiteThree
        }
        
        // card
        content.setup(for: experience, photo: photo)
        
        // overlay
        if let overlay = overlay {
            setupOverlay(overlay: overlay)
        }
        
        // card overlay
        photoOverlay.setup(experience: experience)
        
        // card quote
        quote.setup(for: experience)
    }

    // MARK: - overlay
    
    private func addView(view: UIView, height: CGFloat? = nil, full: Bool = false) {
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: full ? bottomAnchor : safeAreaLayoutGuide.bottomAnchor).isActive = true
        if let height = height {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        } else {
            view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
        setNeedsLayout()
    }
    
    private func setupOverlay(overlay: UIImage) {
        
        overlayView?.removeFromSuperview()
        
        let overlayImage = UIImageView()
        addView(view: overlayImage, full: true)
        overlayImage.backgroundColor = .clear
        overlayImage.contentMode = .bottom
        overlayImage.image = overlay
        
        overlayView = overlayImage
    }
    
    // MARK: - animation
    
    var cardStartFrame: CGRect = .zero
    var cardEndFrame: CGRect = .zero
    var photoStartFrame: CGRect = .zero
    var photoEndFrame: CGRect = .zero
    
    private var cardWidth: CGFloat {
        return cardStartFrame.width + (cardEndFrame.width - cardStartFrame.width) * progress
    }
    
    private var cardHeight: CGFloat {
        return cardStartFrame.height + (cardEndFrame.height - cardStartFrame.height) * progress
    }
    
    private var cardTop: CGFloat {
        return cardStartFrame.minY + (cardEndFrame.minY - cardStartFrame.minY) * progress
    }
    
    private var photoHeight: CGFloat {
        return photoEndFrame.height
    }
    
    var progress: CGFloat = 0 {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        // header
        topFade.layer.transform = CATransform3DMakeTranslation(0, -120 * (1 - progress), 0)
        
        // card
        widthConstraint.constant = cardWidth
        heightConstraint.constant = cardHeight
        topConstraint.constant = cardTop
        content.creatorView.alpha = (1 - progress)

        // overlay
        overlayView?.layer.transform = CATransform3DMakeTranslation(0, 300 * (1 - progress), 0)
        
        // card overlay
        photoHeightConstraint.constant = photoHeight
        photoOverlay.alpha = progress
        photoOverlay.layer.transform = CATransform3DMakeTranslation(0, 400 * (1 - progress), 0)
        
        // card quote
        quote.alpha = 1
        quote.layer.transform = CATransform3DMakeTranslation(0, 400 * (1 - progress), 0)
        
        layoutIfNeeded()
    }

}
