//
//  CreateSignalPhotoSourceButton.swift
//  More
//
//  Created by Luko Gjenero on 16/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CreateSignalPhotoSourceButton: LoadableView {

    enum SourceType: String {
        case search, upload, take
        
        var iconOn: String {
            switch self {
            case .search:
                return "create-photo-search-on"
            case .upload:
                return "create-photo-upload-on"
            case .take:
                return "create-photo-take-on"
            }
        }
        
        var iconOff: String {
            switch self {
            case .search:
                return "create-photo-search-off"
            case .upload:
                return "create-photo-upload-off"
            case .take:
                return "create-photo-take-off"
            }
        }
    }
    
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    var labelTextColor: UIColor = .black
    var labelSelectedTextColor: UIColor = UIColor(white: 1, alpha: 1)
    var labelBackgroundColor: UIColor = UIColor(white: 1, alpha: 1)
    var labelSelectedBackgroundColor: UIColor = .black
    
    var tap: (()->())?

    var selected: Bool = false {
        didSet {
            updateSelectedState()
        }
    }
    
    var sourceType: SourceType = .search {
        didSet {
            label.text = sourceType.rawValue.uppercased()
            updateSelectedState()
        }
    }
    
    override func setupNib() {
        super.setupNib()
        
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        image.layer.cornerRadius = (frame.height - 16) / 2
        
        enableShadow(color: .black, path: UIBezierPath(roundedRect: CGRect(x: 0, y: frame.height - 22, width: frame.width, height: 22), cornerRadius: 11).cgPath)
    }
    
    @IBAction private func buttonTouch(_ sender: Any) {
        tap?()
    }
    
    private func updateSelectedState() {
        if selected {
            image.image = UIImage(named: sourceType.iconOn)
            label.textColor = labelSelectedTextColor
            label.backgroundColor = labelSelectedBackgroundColor
        } else {
            image.image = UIImage(named: sourceType.iconOff)
            label.textColor = labelTextColor
            label.backgroundColor = labelBackgroundColor
        }
    }
    
    
}
