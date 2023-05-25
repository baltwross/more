//
//  ExploreCollectionViewCell.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var content: ExploreCollectionViewCellContent!
    
    var experience: Experience?
    
    var likeTap: ((_ liked: Bool)->())?
    var creatorTap: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        content.likeTap = { [weak self] liked in
            self?.likeTap?(liked)
        }
        content.creatorTap = { [weak self] in
            self?.creatorTap?()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        enableCardShadow(color: .black, path: UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath)
    }
    
    func setup(for experience: Experience) {
        self.experience = experience
        content.setup(for: experience)
    }
    
    func setupLikes(_ liked: Bool) {
        content.setupLikes(liked)
    }
    
    var image: UIImageView! {
        return content.image
    }
    
    var video: MoreVideoView! {
        return content.video
    }
    
    var videoSnapshot: UIImage? {
        return content.video.snapshot()
    }
    
    func setupEmpty() {
        content.setupEmpty()
    }
    
    func animate() {
        content.animate()
    }
    
    func shownOnTop() {
        guard let e = experience else { return }
        guard let updated = ExperienceTrackingService.shared.updatedExperienceData(for: e.id) else { return }
        guard updated.activePost() != nil else { return }

        content.showTimer(experience: updated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        content.reset()
    }
    
    func start() {
        content.start()
    }
    
    func pause() {
        content.pause()
    }
}
