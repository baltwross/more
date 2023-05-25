//
//  Data.swift
//  More
//
//  Created by Luko Gjenero on 05/11/2018.
//  Copyright © 2018 More Technologies. All rights reserved.
//

import UIKit
import Firebase

protocol MoreDataObject: Codable, Hashable {
    
    var id: String { get }
    
    associatedtype ObjectType = Self
    
    var json: [String: Any]? { get }
    
    static func fromJson(_ json: [String: Any]) -> ObjectType?
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ObjectType?
    
    static func convertList<T: MoreDataObject>(_ list: [T]?) -> [String: Any]?
    
    static func convertListBack<T: MoreDataObject>(_ convertedList: [String: Any]?) -> [T]?
}

extension MoreDataObject {
    
    static func convertList<T: MoreDataObject>(_ list: [T]?) -> [String: Any]? {
        if let list = list {
            var convertedList: [String: Any] = [:]
            for item in list {
                convertedList[item.id] = item.json
            }
            return convertedList
        }
        return nil
    }
    
    static func convertListBack<T: MoreDataObject>(_ convertedList: [String: Any]?) -> [T]? {
        if let convertedList = convertedList {
            var list: [T] = []
            for item in convertedList {
                if var itemJson = item.value as? [String: Any] {
                    itemJson["id"] = item.key
                    if let item = T.fromJson(itemJson) as? T {
                        list.append(item)
                    }
                }
            }
            return list
        }
        return nil
    }
}

