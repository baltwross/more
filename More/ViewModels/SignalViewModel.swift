//
//  SignalViewModel.swift
//  More
//
//  Created by Luko Gjenero on 09/10/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import CoreLocation
import IGListKit
import Firebase

class SignalViewModel: Codable, Hashable, NSCopying {
    
    let data: Signal
    
    let id: String
    
    let creator: UserViewModel
    
    let createdAt: Date
    let expiresAt: Date
    
    let imageUrls: [String]
    
    let kind: SignalKind
    let type: SignalType
    let title: String?
    let quote: String
    
    let lastReview: ReviewViewModel?
    
    let location: GeoPoint?
    let destination: GeoPoint?
    let destinationName: String?
    let destinationAddress: String?
    
    let mine: Bool
    let requested: Bool
    let accepted: Bool
    
    let requests: [RequestViewModel]
    
    init(signal: Signal) {
        
        data = signal
        
        id = signal.id
        
        creator = UserViewModel(user: signal.creator)
        
        createdAt = signal.createdAt
        
        imageUrls = signal.images.map { $0.url }
        
        kind = signal.kind ?? .standard
        type = signal.type
        
        title = signal.title
        quote = signal.text
        
        if let last = signal.creator.lastReview {
            lastReview = ReviewViewModel(review: last)
        } else {
            lastReview = nil
        }
        
        location = signal.location
        if let destination = signal.destination {
            self.destination = destination
            destinationName = signal.destinationName
            destinationAddress = signal.destinationAddress
        } else {
            destination = nil
            destinationName = nil
            destinationAddress = nil
        }
                
        mine = signal.isMine()
        requested = signal.haveRequested()
        accepted = signal.wasAccepted()
        
        expiresAt = signal.finalExpiration()
        
        if mine {
            requests = signal.requests?.map { RequestViewModel(request: $0) } ?? []
        } else {
            if let myRequest = signal.myRequest() {
                requests = [RequestViewModel(request: myRequest)]
            } else {
                requests = []
            }
        }
    }
    
    /*
    init(signal: ShortSignal) {
        id = signal.id
        
        creator = UserViewModel(user: signal.creator)
        
        createdAt = Date()
        
        imageUrls = signal.images?.map { $0.url } ?? []
        
        kind = .standard
        type = signal.type
        
        quote = signal.text ?? ""
        
        lastReview = nil
        
        location = signal.creator.location
        destination = nil
        destinationName = nil
        destinationAddress = nil
        
        mine = signal.isMine()
        requested = true
        accepted = true
        
        expiresAt = Date()
        
        requests = []
    }
    */
    
    private init(signal: SignalViewModel) {
        data = signal.data
        id = signal.id
        creator = signal.creator
        createdAt = signal.createdAt
        imageUrls = signal.imageUrls
        kind = signal.kind
        type = signal.type
        title = signal.title
        quote = signal.quote
        lastReview = signal.lastReview
        location = signal.location
        destination = signal.destination
        destinationName = signal.destinationName
        destinationAddress = signal.destinationAddress
        mine = signal.mine
        requested = signal.requested
        accepted = signal.accepted
        expiresAt = signal.expiresAt
        requests = signal.requests
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SignalViewModel, rhs: SignalViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return SignalViewModel(signal: self)
    }
    
}

extension SignalViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? SignalViewModel {
            return self == other
        }
        return false
    }
}
