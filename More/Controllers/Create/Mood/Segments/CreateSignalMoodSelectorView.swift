//
//  CreateSignalMoodSelectorView.swift
//  More
//
//  Created by Luko Gjenero on 20/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

private let cellIdentifier = "Cell"

@IBDesignable
class CreateSignalMoodSelectorView: MoodSelectionView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customSetup()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        customSetup()
    }
    
    private func customSetup() {
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 48
            layout.minimumInteritemSpacing = 40
        }
        selectionNumber = 1
        canUnselect = true
        contentInset = UIEdgeInsets(top: 25, left: 48, bottom: 25, right: 48)
        
        register(Cell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    override var itemSize: CGSize {
        return CGSize(width: 100, height: 111)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? Cell {
            let type = types[indexPath.item]
            cell.setup(for: type, selected: selected.contains(type))
            return cell
        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        if velocity.y != 0 {
            let itemHeight = itemSize.height + layout.minimumLineSpacing
            var row = round((targetContentOffset.pointee.y + contentInset.top) / itemHeight)
            row = max(0, min(ceil(CGFloat(types.count / 2)), row))
            targetContentOffset.pointee = CGPoint(x: 0, y: row * itemHeight - contentInset.top)
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        if !decelerate {
            if layout.scrollDirection == .vertical {
                let itemHeight = itemSize.height + layout.minimumLineSpacing
                var row = round((contentOffset.y + contentInset.top) / itemHeight)
                row = max(0, min(ceil(CGFloat(types.count / 2)), row))
                scrollToItem(at: IndexPath(item: Int(row * 2), section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    // MARK: - Cell
    
    private class Cell: MoodCell {
        
        private let imageView: UIImageView = {
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .scaleAspectFill
            image.layer.masksToBounds = true
            image.backgroundColor = .clear
            return image
        }()
        
        private let labelView: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: "Gotham-Bold", size: 11)
            label.textColor = UIColor(red: 255, green: 255, blue: 255)
            label.textAlignment = .center
            label.backgroundColor = .black
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 11
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            
            contentView.addSubview(imageView)
            contentView.addSubview(labelView)
            
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            
            labelView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            labelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            labelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            labelView.heightAnchor.constraint(equalToConstant: 22).isActive = true

            contentView.setNeedsLayout()
            
            enableShadow(color: .black)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func setup(for type: SignalType, selected: Bool) {
            if selected {
                labelView.textColor = UIColor(red: 255, green: 255, blue: 255)
                labelView.backgroundColor = .black
                labelView.text = type.rawValue.uppercased()
                imageView.image = SignalType.image(for: type)
            } else {
                labelView.textColor = .black
                labelView.backgroundColor = UIColor(red: 255, green: 255, blue: 255)
                labelView.text = type.rawValue.uppercased()
                imageView.image = SignalType.grayscaleImage(for: type)
            }
        }
    }
    
}
