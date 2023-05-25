//
//  ProfilePhotosCell.swift
//  More
//
//  Created by Luko Gjenero on 18/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

private let photoAspect:CGFloat = 375 / 281

class ProfilePhotosCell: ProfileBaseCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private static let cellIdentifier = "ImageCell"
    
    @IBOutlet private weak var photos: UICollectionView!
    @IBOutlet private weak var page: UIPageControl!
    @IBOutlet private weak var placeholderImage: UIImageView!
    @IBOutlet private weak var gradient: VerticalGradientView!
    @IBOutlet private weak var edit: UIButton!
    
    private var photoURLs: [String] = []
    
    var editTap: (()->())?
    
    var placeholder: UIImage? {
        get {
            return placeholderImage.image
        }
        set {
            placeholderImage.image = newValue
            placeholderImage.isHidden = newValue == nil
        }
    }
    
    func currentPhoto() -> UIView? {
        if let cell = photos.cellForItem(at: IndexPath(item: page.currentPage, section: 0)) as? Cell {
            return cell.image
        }
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gradient.colors = [
            UIColor.lightPeriwinkle.cgColor,
            UIColor(red: 167, green: 173, blue: 183).cgColor
        ]
        
        photos.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Dummy")
        photos.register(Cell.self, forCellWithReuseIdentifier: ProfilePhotosCell.cellIdentifier)
        photos.dataSource = self
        photos.delegate = self
        
        page.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
        
        edit.layer.cornerRadius = 22.5
        edit.enableShadow(color: .black, path: UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 45, height: 45)).cgPath)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = photos.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemSize = self.itemSize
            if itemSize.width != layout.itemSize.width || itemSize.height != itemSize.height {
                layout.itemSize = itemSize
                photos.collectionViewLayout.invalidateLayout()
                photos.reloadData()
            }
        }
    }
    
    private var itemSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height - 30)
    }
    
    @IBAction private func editTouch() {
        editTap?()
    }
    
    @objc private func pageChanged() {
        photos.scrollToItem(at: IndexPath(item: page.currentPage, section: 0), at: .left, animated: true)
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePhotosCell.cellIdentifier, for: indexPath) as? Cell {
            cell.setup(for: photoURLs[indexPath.item])
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Dummy", for: indexPath)
    }
    
    // MARK: - delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = max(0,min(Int(round(scrollView.contentOffset.x / scrollView.frame.width)), photoURLs.count))
        page.currentPage = currentPage
    }
    
    // MARK: - cell
    
    private class Cell: UICollectionViewCell {
        
        fileprivate let image: UIImageView = {
            let image = UIImageView(frame: .zero)
            image.translatesAutoresizingMaskIntoConstraints = false
            image.backgroundColor = .clear
            image.contentMode = .scaleAspectFill
            image.clipsToBounds = true
            return image
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            clipsToBounds = false
            contentView.clipsToBounds = false
            contentView.addSubview(image)
            image.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            image.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            image.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            contentView.setNeedsLayout()
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
            
            image.sd_progressive_setImage(with: url, placeholderImage: UIImage.profilePlaceholder(), options: .highPriority)
        }
    }
    
    // MARK: - base
    
    override func setup(for model: UserViewModel) {
        photoURLs = model.imageUrls
        photos.collectionViewLayout.invalidateLayout()
        photos.reloadData()
        
        page.numberOfPages = photoURLs.count
        page.isHidden = photoURLs.count <= 1
        
        edit.isHidden = !model.user.isMe()
    }
    
    override class func size(for model: UserViewModel, in size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: size.width / photoAspect + 30)
    }
    
    override class func isShowing(for model: UserViewModel) -> Bool {
        return true
    }
}
