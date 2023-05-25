//
//  ExploreCollectionViewCellContent.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

private let spacing: CGFloat = 10

@IBDesignable
class ExploreCollectionViewCellContent: LoadableView {

    @IBOutlet private weak var view: VerticalGradientView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var video: MoreVideoView!
    @IBOutlet private weak var typeLabel: HorizontalGradientLabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var quoteLabel: UILabel!
    @IBOutlet private weak var bottomGradient: VerticalGradientView!
    @IBOutlet private weak var virtualTag: UILabel!
    @IBOutlet weak var creatorView: ExperienceCreatorView!
    @IBOutlet private weak var likeView: UIButton!
    
    // timer
    @IBOutlet private weak var timerContainer: HorizontalGradientView!
    @IBOutlet private weak var timerLabel: UILabel!
    private var timer: Timer?
    private var fadeTimer: Timer?
    
    var likeTap: ((_ liked: Bool)->())?
    var creatorTap: (()->())?
    
    override func setupNib() {
        super.setupNib()
        
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        view.colors = [
            UIColor(red: 255, green: 255, blue: 255).cgColor,
            UIColor(red: 249, green: 249, blue: 249).cgColor
        ]
        view.locations = [0, 1]
        
        video.contentMode = .scaleAspectFill
        
        timerContainer.layer.masksToBounds = true
        timerContainer.layer.cornerRadius = 15
        timerContainer.colors = [
            UIColor(red: 3, green: 255, blue: 191).cgColor,
            UIColor.brightSkyBlue.cgColor,
            UIColor(red: 48, green: 183, blue: 255).cgColor,
            UIColor.periwinkle.cgColor
        ]
        timerContainer.locations = [0, 0.32, 0.6, 1]
        
        bottomGradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.35).cgColor
        ]
        
        let inset = spacing / 2
        likeView.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10 + inset, bottom: 0, right: 10 + inset)
        likeView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -inset, bottom: 0, right: inset)
        likeView.titleEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: -inset)
        
        creatorView.profileTap = { [weak self] in
            self?.creatorTap?()
        }
    }
    
    func setup(for experience: Experience, photo: UIImage? = nil) {
        if let photo = photo {
            video.reset()
            video.isHidden = true
            image.isHidden = false
            image.image = photo
        } else {
            if let first = experience.images.first {
                if first.isVideo == true {
                    video.isHidden = false
                    image.isHidden = true
                    if let url = URL(string: first.url) {
                        video.setup(for: url, preview: URL(string: first.previewUrl ?? ""))
                        video.isSilent = true
                        video.play(loop: true)
                    } else {
                        video.reset()
                    }
                } else {
                    video.isHidden = true
                    image.isHidden = false
                    image.sd_progressive_setImage(with: URL(string: experience.images.first?.url ?? ""), placeholderImage: UIImage.signalPlaceholder(), options: SDWebImageOptions.highPriority)
                }
            } else {
                video.isHidden = true
                image.isHidden = false
                image.sd_cancelCurrentImageLoad_progressive()
            }
        }
        typeLabel.gradientColors = [experience.type.gradient.0.cgColor, experience.type.gradient.1.cgColor]
        typeLabel.text = experience.type.rawValue.uppercased()
        
        likeView.isHidden = false
        creatorView.isHidden = false
        creatorView.setup(for: experience.creator.short())
        virtualTag.isHidden = true // !(experience.isVirtual ?? false)
        likeView.isSelected = false
        if let numOfLikes = experience.numOfLikes, numOfLikes >= ConfigService.shared.likesThreshold {
            let suffix = numOfLikes == 1 ? "like" : "likes"
            likeView.setTitle("\(numOfLikes) \(suffix)", for: .normal)
        } else {
            likeView.setTitle("", for: .normal)
        }
        loadLikes(for: experience)
        
        setTitleAndText(title: experience.title, text: experience.text)
        
        setupTimer(for: experience)
    }
    
    func setupLikes(_ liked: Bool) {
        likeView.isSelected = liked
    }
    
    func setupEmpty() {
        video.reset()
        video.isHidden = true
        image.isHidden = false
        image.sd_cancelCurrentImageLoad_progressive()
        image.image = nil
        typeLabel.text = ""
        titleLabel.text = ""
        quoteLabel.text = ""
        timerContainer.isHidden = true
        
        likeView.isHidden = true
        creatorView.isHidden = true
        virtualTag.isHidden = true
    }
    
    func animate() {
        view.animate(to: [
            UIColor(red: 210, green: 210, blue: 210).cgColor,
            UIColor(red: 240, green: 240, blue: 240).cgColor
        ])
    }
    
    func reset() {
        view.layer.removeAllAnimations()
        timer?.invalidate()
        video.reset()
    }
    
    func start() {
        if !video.isHidden, !video.isPlaying {
            video.play(loop: true)
        }
    }
    
    func pause() {
        if !video.isHidden {
            video.pause()
        }
    }
    
    func showTimer(experience: Experience) {
        
        let alpha = timerContainer.alpha
        setupTimer(for: experience)
        timerContainer.alpha = alpha
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.timerContainer.alpha = 1
        }
        
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { [weak self] _ in
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self?.timerContainer.alpha = 0
                })
        })
    }
    
    // MARK: - helpers
    
    private func setTitleAndText(title: String?, text: String) {
        if let title = title {
            titleLabel.font = UIFont(name: "Gotham-Black", size: 25)
            titleLabel.text = title
            quoteLabel.text = text
        } else {
            titleLabel.font = UIFont(name: "Gotham-Black", size: 16)
            titleLabel.text = text
            quoteLabel.text = ""
        }
    }
    
    private func setupTimer(for experience: Experience) {
        if let post = experience.activePost() {
            timerContainer.isHidden = false
            timerContainer.alpha = 0
            fadeTimer?.invalidate()
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] _ in
                
                let left = Int(round(post.expiresAt.timeIntervalSinceNow))
                let hours = left / 3600
                let minutes = (left / 60) % 60
                let seconds = left % 60
                
                if hours > 0 {
                    self?.timerLabel.text = "Time expires in \(hours):\(String(format: "%02d",minutes)):\(String(format: "%02d", seconds))"
                } else {
                    self?.timerLabel.text = "Time expires in \(minutes):\(String(format: "%02d", seconds))"
                }
                
                if left < 1 {
                    self?.timerContainer.isHidden = true
                    self?.timer?.invalidate()
                }
            })
        } else {
            timerContainer.isHidden = true
        }
    }
    
    // MARK: - likes
    
    @IBAction private func likeTouch(_ sender: Any) {
        if ConfigService.shared.canRemoveLike || !likeView.isSelected {
            likeTap?(likeView.isSelected)
        }
    }
    
    private func loadLikes(for experience: Experience) {
        likeView.isUserInteractionEnabled = false
        ExperienceService.shared.haveLikedExperience(experienceId: experience.id) { [weak self] (liked, _) in
            if let liked = liked {
                self?.setupLikes(liked)
            }
            self?.likeView.isUserInteractionEnabled = true
        }
    }
}
