//
//  RequestViewModel.swift
//  More
//
//  Created by Luko Gjenero on 05/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Firebase

class RequestViewModel: Codable, Hashable {

    let id: String
    let createdAt: Date
    let expiresAt: Date
    let sender: UserViewModel
    let location: GeoPoint?
    let accepted: Bool
    
    init(request: Request) {
        id = request.id
        createdAt = request.createdAt
        expiresAt = request.expiresAt
        sender = UserViewModel(user: request.sender)
        location = request.location
        accepted = request.accepted ?? false
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RequestViewModel, rhs: RequestViewModel) -> Bool {
        return lhs.id == rhs.id
    }
}
