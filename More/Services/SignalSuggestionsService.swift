//
//  SignalSuggestionsService.swift
//  More
//
//  Created by Luko Gjenero on 14/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

class SignalSuggestionsService {
    
    struct Notifications {
        static let SuggestionsLoaded = NSNotification.Name(rawValue: "com.more.suggestions.loaded")
    }
    
    static let shared = SignalSuggestionsService()
    
    private(set) var suggestions: [ExperiencePlaceSuggestion] = []
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: LocationService.Notifications.LocationDescriptionUpdate, object: nil)
        
        DispatchQueue.main.async { [weak self] in
            self?.toForeground()
        }
    }
    
    @objc private func toForeground() {
        load()
    }
    
    @objc private func toBackground() {
        // nothing
    }
    
    @objc private func locationUpdated() {
        load()
    }
    
    private func load() {
        
        // start with neighbourhood
        let hood = ExperienceService.Helper.sanitize(LocationService.shared.neighbourhood)
        if !hood.isEmpty {
            Firestore.firestore().collection("neighbourhoodSuggestions/\(hood)/places").getDocuments { [weak self] (snapshot, error) in
                if let snapshot = snapshot, !snapshot.isEmpty {
                    var suggestions: [ExperiencePlaceSuggestion] = []
                    for child in snapshot.documents {
                        if let suggestion = ExperiencePlaceSuggestion.fromSnapshot(child) {
                            suggestions.append(suggestion)
                        }
                    }
                    suggestions.sort(by: { (lhs, rhs) -> Bool in
                        return lhs.order < rhs.order
                    })
                    self?.updateSuggestions(to: suggestions)
                } else {
                    self?.loadCitySuggestions()
                }
            }
        } else {
            loadCitySuggestions()
        }
    }
    
    private func loadCitySuggestions() {
        let city = LocationService.shared.city
        if !city.isEmpty {
            Firestore.firestore().collection("citySuggestions/\(city)/places").getDocuments { [weak self] (snapshot, error) in
                if let snapshot = snapshot, !snapshot.isEmpty {
                    var suggestions: [ExperiencePlaceSuggestion] = []
                    for child in snapshot.documents {
                        if let suggestion = ExperiencePlaceSuggestion.fromSnapshot(child) {
                            suggestions.append(suggestion)
                        }
                    }
                    suggestions.sort(by: { (lhs, rhs) -> Bool in
                        return lhs.order < rhs.order
                    })
                    self?.updateSuggestions(to: suggestions)
                } else {
                    self?.loadStateSuggestions()
                }
            }
        } else {
            loadStateSuggestions()
        }
    }
    
    private func loadStateSuggestions() {
        let state = LocationService.shared.state
        if !state.isEmpty {
            Firestore.firestore().collection("stateSuggestions/\(state)/places").getDocuments { [weak self] (snapshot, error) in
                if let snapshot = snapshot, !snapshot.isEmpty {
                    var suggestions: [ExperiencePlaceSuggestion] = []
                    for child in snapshot.documents {
                        if let suggestion = ExperiencePlaceSuggestion.fromSnapshot(child) {
                            suggestions.append(suggestion)
                        }
                    }
                    suggestions.sort(by: { (lhs, rhs) -> Bool in
                        return lhs.order < rhs.order
                    })
                    self?.updateSuggestions(to: suggestions)
                }
            }
        }
    }
    
    private func updateSuggestions(to suggestions: [ExperiencePlaceSuggestion]) {
        self.suggestions = suggestions
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notifications.SuggestionsLoaded, object: nil)
        }
    }
    
    private func loadMock() {
        // MOCK
        suggestions = [
            gramercy, chelsea, tribeca, soho, ny
        ]
        
        NotificationCenter.default.post(name: Notifications.SuggestionsLoaded, object: nil)
    }
    
}

// MARK: - mock

private let gramercy =  ExperiencePlaceSuggestion(id: "1", name: "Gramercy", address: "Gramercy Park, New York, NY", image: Image(id: "1", url: "https://imgs.6sqft.com/wp-content/uploads/2014/08/21033426/gramercy-park-5.jpg", path: "", order: 1), location: GeoPoint(latitude: 40.736114, longitude: -73.984306), neighbourhood: "gramercy", city: nil, state: nil, order: 1)

private let chelsea =  ExperiencePlaceSuggestion(id: "2", name: "Chelsea", address: "Chelsea, New York, NY", image: Image(id: "1", url: "https://nyc.socialinnovation.org/sites/default/files/pictures/neighbourhood.jpg", path: "", order: 1), location: GeoPoint(latitude: 40.748271, longitude: -74.000044), neighbourhood: "chelsea", city: nil, state: nil, order: 2)

private let tribeca =  ExperiencePlaceSuggestion(id: "3", name: "Tribeca", address: "Tribeca, New York, NY", image: Image(id: "1", url: "https://loving-newyork.com/wp-content/uploads/2018/11/Things-To-Do-In-Tribeca-181012130243007-1600px-1600x960.jpg", path: "", order: 1), location: GeoPoint(latitude: 40.718579, longitude: -74.008513), neighbourhood: "tribeca", city: nil, state: nil, order: 3)

private let soho =  ExperiencePlaceSuggestion(id: "4", name: "Soho", address: "Soho, New York, NY", image: Image(id: "1", url: "https://i.ytimg.com/vi/3_nP6XCvb6k/maxresdefault.jpg", path: "", order: 1), location: GeoPoint(latitude: 40.723921, longitude: -74.001044), neighbourhood: "soho", city: nil, state: nil, order: 4)

private let ny =  ExperiencePlaceSuggestion(id: "5", name: "New York", address: "New York, NY", image: Image(id: "1", url: "https://cdn.getyourguide.com/img/tour_img-1096032-146.jpg", path: "", order: 1), location: GeoPoint(latitude: 40.723922, longitude: -74.001043), neighbourhood: nil, city: "new york", state: nil, order: 5)



