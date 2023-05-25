//
//  Image.swift
//  More
//
//  Created by Luko Gjenero on 10/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

class Image: MoreDataObject {
    
    let id: String
    let url: String
    let path: String
    let order: Int
    
    let isVideo: Bool?
    let previewUrl: String?
    let previewPath: String?
    
    init(id: String,
         url: String,
         path: String,
         order: Int,
         isVideo: Bool? = nil,
         previewUrl: String? = nil,
         previewPath: String? = nil) {
        self.id = id
        self.url = url
        self.path = path
        self.order = order
        self.isVideo = isVideo
        self.previewUrl = previewUrl
        self.previewPath = previewPath
    }
    
    convenience init() {
        self.init(id: "", url: "", path: "", order: 0, isVideo: nil)
    }
    
    func imageWithOrder(_ order: Int) -> Image {
        return Image(id: id, url: url, path: path, order: order, isVideo: isVideo, previewUrl: previewUrl, previewPath: previewPath)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Image, rhs: Image) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Data protocol
    
    var json: [String : Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String : Any]) -> Image? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
            let image = try? JSONDecoder().decode(Image.self, from: jsonData) {
            return image
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> Image? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return Image.fromJson(json)
        }
        return nil
    }
}
