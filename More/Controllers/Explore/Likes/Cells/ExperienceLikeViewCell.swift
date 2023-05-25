//
//  ExperienceLikeViewCell.swift
//  More
//
//  Created by Luko Gjenero on 24/02/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import UIKit

class ExperienceLikeViewCell: UITableViewCell {
    
    @IBOutlet private weak var avatar: AvatarImage!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setup(for item: ExperienceLike) {
        if let url = URL(string: item.creator.avatar) {
            avatar.sd_progressive_setImage(with: url, placeholderImage: UIImage.profileThumbPlaceholder())
        } else {
            avatar.sd_cancelCurrentImageLoad_progressive()
        }
        name.text = item.creator.name
        time.text = item.createdAt.likeDateFormatted
    }
}

// MARK: - date format

private let minInSecs: TimeInterval = 60
private let hourInSecs: TimeInterval = 3600
private let dayInSecs: TimeInterval = 86400
private let weekInSecs: TimeInterval = 604800

private extension Date {
    var likeDateFormatted: String {
        let timeInSeconds = -timeIntervalSinceNow
        if timeInSeconds > weekInSecs {
            let weeks = Int(timeInSeconds / weekInSecs)
            return "\(weeks)w"
        } else if timeInSeconds > dayInSecs {
            let days = Int(timeInSeconds / dayInSecs)
            return "\(days)d"
        } else if timeInSeconds > hourInSecs {
            let hours = Int(timeInSeconds / hourInSecs)
            return "\(hours)h"
        }
        let mins = Int(min(1,timeInSeconds / minInSecs))
        return "\(mins)m"
    }
}
