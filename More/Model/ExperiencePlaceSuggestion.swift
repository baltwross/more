//
//  ExperiencePlaceSuggestion.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

class ExperiencePlaceSuggestion: MoreDataObject {
    
    let id: String
    let name: String
    let address: String
    let image: Image?
    let location: GeoPoint?
    let neighbourhood: String?
    let city: String?
    let state: String?
    let order: Int
    
    init(id: String,
         name: String,
         address: String,
         image: Image?,
         location: GeoPoint?,
         neighbourhood: String?,
         city: String?,
         state: String?,
         order: Int) {
        
        self.id = id
        self.name = name
        self.address = address
        self.image = image
        self.location = location
        self.neighbourhood = neighbourhood
        self.city = city
        self.state = state
        self.order = order
    }
    
    func suggestionlWithLocation(_ location: GeoPoint?) -> ExperiencePlaceSuggestion {
        return ExperiencePlaceSuggestion(id: id,
                                         name: name,
                                         address: address,
                                         image: image,
                                         location: location,
                                         neighbourhood: neighbourhood,
                                         city: city,
                                         state: state,
                                         order: order)
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExperiencePlaceSuggestion, rhs: ExperiencePlaceSuggestion) -> Bool {
        return lhs.id == rhs.id
    }
    
    // JSON
    
    var json: [String: Any]? {
        get {
            if let jsonData = try? JSONEncoder().encode(self),
                var json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                json.removeValue(forKey: "id")
                json["location"] = location
                return json
            }
            return nil
        }
    }
    
    static func fromJson(_ json: [String: Any]) -> ExperiencePlaceSuggestion? {
        let location: GeoPoint? = json["location"] as? GeoPoint
        var rectifiedJson = json
        rectifiedJson.removeValue(forKey: "location")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rectifiedJson, options: []),
            var sugestion = try? JSONDecoder().decode(ExperiencePlaceSuggestion.self, from: jsonData) {

            if let location = location {
                sugestion = sugestion.suggestionlWithLocation(location)
            }
            
            return sugestion
        }
        return nil
    }
    
    static func fromSnapshot(_ snapshot: DocumentSnapshot) -> ExperiencePlaceSuggestion? {
        if var json = snapshot.data() {
            json["id"] = snapshot.documentID
            return ExperiencePlaceSuggestion.fromJson(json)
        }
        return nil
    }

}
