//
//  SimpleStoreService.swift
//  More
//
//  Created by Luko Gjenero on 07/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit

class SimpleStoreService {
    
    typealias CodableClass = AnyObject & Codable
    
    static let shared = SimpleStoreService()
    
    class StoreItem : Codable {
        let key: String
        var value: Codable?
        
        enum CodingKeys: String, CodingKey {
            case key = "key"
            case value = "value"
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            key = try container.decode(String.self, forKey: .key)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(key, forKey: .key)
        }
        
        init(key: String, value: Codable?) {
            self.key = key
            self.value = value
        }
    }
    
    private let storeKey = "com.more.simpleStore.data"
    
    func store(item: StoreItem) {
        let keyType = String(describing: type(of: item))
        let defaultsKey = storeKey + "-" + keyType + "-" + item.key
        UserDefaults.standard.set(try? PropertyListEncoder().encode(item), forKey: defaultsKey)
    }
    
    func remove(forKey key: String, type: StoreItem.Type) {
        let keyType = String(describing: type)
        let defaultsKey = storeKey + "-" + keyType + "-" + key
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
    
    func get<T: StoreItem>(forKey key: String) -> T? {
        let keyType = String(describing: T.self)
        let defaultsKey = storeKey + "-" + keyType + "-" + key
        if let data = UserDefaults.standard.value(forKey: defaultsKey) as? Data,
            let item = try? PropertyListDecoder().decode(T.self, from: data) {
            return item
        }
        return nil
    }

}
