//
//  MessageViewModel.swift
//  More
//
//  Created by Luko Gjenero on 24/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class MessageViewModel: Codable, Hashable {
    
    let id: String
    
    let sender: UserViewModel
    
    let createdAt: Date
    let text: String
    let delivered: Date?
    let read: Date?
    
    let isTyping: Bool?
    
    init(id: String, text: String, signal: Signal, creator: User) {
        
        self.id = id
        
        self.sender = UserViewModel(user: creator)
        
        createdAt = Date(timeIntervalSinceNow: -30)
        self.text = text
        delivered = Date(timeIntervalSinceNow: -10)
        read = Date(timeIntervalSinceNow: -10)
        
        isTyping = nil
    }
    
    init(message: Message) {
        id = message.id
        
        sender = UserViewModel(user: message.sender)
        
        createdAt = message.createdAt
        text = message.text
        delivered = message.deliveredAt?.values.sorted().first
        read = message.readAt?.values.sorted().first
        
        isTyping = nil
    }
    
    init(isTyping: Bool) {
        id = "typing"
        
        sender = UserViewModel(user: User())
        
        createdAt = Date(timeIntervalSinceNow: 86400)
        text = ""
        delivered = nil
        read = nil
        
        self.isTyping = isTyping
    }
    
    func isMine() -> Bool {
        return sender.id == ProfileService.shared.profile?.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        return lhs.id == rhs.id
    }

}
