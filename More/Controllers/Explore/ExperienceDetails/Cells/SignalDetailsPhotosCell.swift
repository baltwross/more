//
//  SignalDetailsPhotosCell.swift
//  More
//
//  Created by Luko Gjenero on 15/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import SDWebImage

private let imageCell = "ImageCell"
private let videoCell = "VideoCell"

private let gradientHeight: CGFloat = 167

class SignalDetailsPhotosCell: SignalDetailsBaseCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    static let photoAspect: CGFloat = 4/3
    
    @IBOutlet private weak var photos: UICollectionView!
    @IBOutlet private weak var page: UIPageControl!
    @IBOutlet private weak var status: ExperienceStatusView!
    @IBOutlet private weak var gradientView: UIView!
    
    private let gradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.whiteTwo.cgColor,
                        UIColor.whiteTwo.withAlphaComponent(0).cgColor]
        layer.locations = [0, 1.0]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    private var images: [Image] = []
    private var modelPhotos: [CreateExperienceViewModel.Photo] = []
    
    private var usePhotos: Bool {
        return modelPhotos.count > images.count
    }
    
    var share: (()->())?
    var like: (()->())?
    var creator: (()->())?
    var scrolling: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        /*
        layer.zPosition = 1000
        gradient.backgroundColor = UIColor.red.cgColor
        */
        
        gradientView.layer.addSublayer(gradient)

        photos.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        photos.register(ImageCell.self, forCellWithReuseIdentifier: imageCell)
        photos.register(VideoCell.self, forCellWithReuseIdentifier: videoCell)
        
        photos.dataSource = self
        photos.delegate = self
        
        page.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        
        status.share = { [weak self] in
            self?.share?()
        }
        
        status.like = { [weak self] in
            self?.like?()
        }
        
        status.creator = { [weak self] in
            self?.creator?()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.frame = CGRect(x: 0, y: bounds.height - gradientHeight, width: bounds.width, height: gradientHeight)
        
        if let layout = photos.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemSize = bounds.size
            if itemSize.width != layout.itemSize.width || itemSize.height != itemSize.height {
                layout.itemSize = itemSize
                photos.collectionViewLayout.invalidateLayout()
                photos.reloadData()
            }
        }
    }
    
    @objc private func pageChanged() {
        photos.scrollToItem(at: IndexPath(item: page.currentPage, section: 0), at: .left, animated: true)
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if usePhotos {
            return modelPhotos.count
        }
        return images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if usePhotos {
            let photo = modelPhotos[indexPath.item]
            if let video = photo.video {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoCell, for: indexPath) as? VideoCell {
                    cell.setup(for: video)
                    return cell
                }
            } else if let image = photo.image {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCell, for: indexPath) as? ImageCell {
                    cell.setup(for: image)
                    return cell
                }
            }
        } else {
            let image = images[indexPath.item]
            if image.isVideo == true {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoCell, for: indexPath) as? VideoCell {
                    cell.setup(for: image.url, preview: image.previewUrl)
                    return cell
                }
            } else {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCell, for: indexPath) as? ImageCell {
                    cell.setup(for: image.url)
                    return cell
                }
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? VideoCell {
            cell.start()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? VideoCell {
            cell.pause()
        }
    }
    
    // MARK: - delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var currentPage = max(0,min(Int(round(scrollView.contentOffset.x / scrollView.frame.width)), images.count))
        if usePhotos {
            currentPage = max(0,min(Int(round(scrollView.contentOffset.x / scrollView.frame.width)), modelPhotos.count))
        } else {
            play(item: currentPage)
        }
        page.currentPage = currentPage
        scrolling?()
    }
    
    private func play(item: Int) {
        var play = false
        if usePhotos, item < modelPhotos.count, modelPhotos[item].video != nil {
            play = true
        } else if item < images.count, images[item].isVideo == true {
            play = true
        }
        if play, let cell = photos.cellForItem(at: IndexPath(item: item, section: 0)) as? VideoCell {
            cell.start()
        }
    }
    
    // MARK: - cells
    
    private class ImageCell: UICollectionViewCell {
        
        private let image: UIImageView = {
           let image = UIImageView(frame: .zero)
            image.translatesAutoresizingMaskIntoConstraints = false
            image.backgroundColor = .clear
            image.contentMode = .scaleAspectFill
            image.clipsToBounds = true
            return image
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(image)
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            image.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            contentView.layoutIfNeeded()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for url: String) {
            guard let url = URL(string: url) else {
                image.sd_cancelCurrentImageLoad_progressive()
                image.image = nil
                return
            }
            
            image.sd_progressive_setImage(with: url, placeholderImage: UIImage.expandedSignalPlaceholder(), options: .highPriority)
        }
        
        func setup(for image: UIImage?) {
            self.image.sd_cancelCurrentImageLoad_progressive()
            self.image.image = image
        }
    }
    
    private class VideoCell: UICollectionViewCell {
        
        private let video: MoreVideoView = {
           let video = MoreVideoView(frame: .zero)
            video.translatesAutoresizingMaskIntoConstraints = false
            video.backgroundColor = .clear
            video.contentMode = .scaleAspectFill
            video.clipsToBounds = true
            return video
        }()
        
        private let button: UIButton = {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .clear
            button.clipsToBounds = true
            return button
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(video)
            contentView.addSubview(button)
            video.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            video.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            video.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            video.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            button.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            contentView.layoutIfNeeded()
            
            button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(for url: String, preview: String?) {
            guard let url = URL(string: url) else {
                video.reset()
                return
            }
            video.setup(for: url, preview: URL(string: preview ?? ""))
            video.isSilent = false
        }
        
        func setup(for data: Data) {
            video.setup(for: data)
            video.isSilent = false
        }
        
        func start() {
            if !video.isPlaying {
                video.play(loop: true)
            }
        }
        
        func pause() {
            video.pause()
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            video.reset()
        }
        
        @objc private func buttonTap() {
            if video.isPlaying {
                video.pause()
            } else {
                video.play(loop: true) 
            }
        }
    }
    
    // MARK: - experience details view
    
    override class func isShowing(for experience: Experience) -> Bool {
        return true
    }
    
    override func setup(for experience: Experience) {
        images = experience.images
        modelPhotos = []
        photos.collectionViewLayout.invalidateLayout()
        photos.reloadData()
        
        status.isHidden = false
        status.setup(for: experience)
        
        page.numberOfPages = images.count
        page.isHidden = images.count <= 1
        
        play(item: 0)
    }
    
    // MARK: - experience preview
    
    override func setup(for model: CreateExperienceViewModel) {
        images = []
        modelPhotos = model.images
        photos.collectionViewLayout.invalidateLayout()
        photos.reloadData()
        
        status.isHidden = true
        
        page.numberOfPages = modelPhotos.count
        page.isHidden = modelPhotos.count <= 1
        
        play(item: 0)
    }
    
    override class func isShowing(for model: CreateExperienceViewModel) -> Bool {
        return true
    }
}


