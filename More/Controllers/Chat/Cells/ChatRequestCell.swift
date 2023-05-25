//
//  ChatRequestCell.swift
//  More
//
//  Created by Luko Gjenero on 28/07/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

class ChatRequestCell: UITableViewCell {

    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var signalText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func setup(for message: Message, in chat: Chat) {
        date.text = message.createdAt.requestDateFormatted
        setupText(for: message, in: chat)
    }
    
    private func setupText(for message: Message, in chat: Chat) {
        var text: String
        if message.sender.isMe() {
            text = "You requested:"
        } else {
            text = "\(chat.other().name) requested:"
        }
        text += "\n"
        text += message.text
        signalText.text = text
    }
}

// MARK: - date format

private extension Date {
    var requestDateFormatted: String {
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: self)
        
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today \(timeString)"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday \(timeString)"
        }
        
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
        let day = components.day!
        
        let dateFormatter = DateFormatter()
        if day < 7 {
            dateFormatter.dateFormat = "EEE"
        } else {
            dateFormatter.dateFormat = "EEE m/d"
        }
        return "\(dateFormatter.string(from: self)) \(timeString)"
    }
}
