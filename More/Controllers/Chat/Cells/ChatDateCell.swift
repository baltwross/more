//
//  ChatDateCell.swift
//  More
//
//  Created by Luko Gjenero on 17/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ChatDateCell: UITableViewCell {

    @IBOutlet private weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func setup(for date: Date) {
        self.date.text = date.chatDateFormatted
    }
    
}

// MARK: - date format

private extension Date {
    var chatDateFormatted: String {
        
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        }
        
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
        let day = components.day!
        
        let dateFormatter = DateFormatter()
        if day < 7 {
            dateFormatter.dateFormat = "EEEE"
        } else {
            dateFormatter.dateFormat = "EEEE m/d"
        }
        return "\(dateFormatter.string(from: self))"
    }
}
