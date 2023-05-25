//
//  Product.swift
//  More
//
//  Created by Luko Gjenero on 02/05/2020.
//  Copyright © 2020 More Technologies. All rights reserved.
//

import Firebase

class Product: MoreDataObject {
    
    let id: String
    let sku: String
    let title: String
    let description: String
    let enabled: Bool
    
    init(id: String,
         sku: String,
         title: String,
         description: String,
         enabled: Bool) {
        self.id = id
        self.sku = sku
        self.title = title
        self.description = description
        self.enabled = enabled
    }

    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Data protocol
    
    var json: [String : Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> Product? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let call = try? JSONDecoder().decode(Product.self, from: jsonData) {
            return call
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Product? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Product.fromJson(json)
        }
        return nil
    }
    
}
