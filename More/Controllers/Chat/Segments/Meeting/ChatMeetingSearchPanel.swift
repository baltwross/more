//
//  ChatMeetingSearchPanel.swift
//  More
//
//  Created by Luko Gjenero on 13/12/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class ChatMeetingSearchPanel: LoadableView, BufferedRunInterface {

    typealias BufferedData = String
    var buffer: String?
    var bufferDelay: TimeInterval {
        return 0.5
    }
    var bufferTimer: Timer?

    @IBOutlet private weak var topBar: ChatMeetingSearchPanelTopBar!
    @IBOutlet private weak var search: CreateSignalPlaceSearchView!
    @IBOutlet private weak var suggestions: ChatMeetingSuggestionsView!
    @IBOutlet private weak var searchResults: CreateSignalPlaceSearchResultView!
    
    private var post: ExperiencePost?
    private var request: ExperienceRequest?
    
    var backTap: (()->())?
    var doneTap: (()->())?
    var searchFocus: ((_ inFocus: Bool)->())?
    var placeSelected: ((_ place: PlacesSearchService.PlaceData)->())?
    var suggestionSelected: ((_ place: PlacesSearchService.PlaceData, _ type: MeetType)->())?
    
    override func setupNib() {
        super.setupNib()

        suggestions.isHidden = false
        searchResults.isHidden = true
        topBar.doneIsHidden = true
        
        topBar.backTap = { [weak self] in
            self?.backTap?()
        }
        
        topBar.doneTap = { [weak self] in
            self?.doneTap?()
        }
    
        search.placeholder = "Search places"
        search.searchChanged = { [weak self] text in
            self?.searchUpdated(to: text ?? "")
        }
        
        search.searchFocus = { [weak self] inFocus in
            
            self?.suggestions.isHidden = inFocus
            self?.searchResults.isHidden = !inFocus
            
            self?.searchFocus?(inFocus)
        }
        
        searchResults.selected = { [weak self] place in
            self?.placeSelected?(place)
        }
        
        suggestions.selected = { [weak self] meetType in
            self?.suggestionSelected(type: meetType)
        }
    }
    
    func setup(post: ExperiencePost?, request: ExperienceRequest?, type: MeetType?) {
        self.post = post
        self.request = request
        if let experience = ExperienceTrackingService.shared.getTrackedExperiences().first(where: { $0.id == post?.experience.id }),
            experience.neighbourhood != nil || experience.city != nil || experience.state != nil {
            suggestions.items = [.halfway, .near]
        } else {
            suggestions.items = [.halfway, .near, .destination]
        }
        if let type = type {
            suggestions.select(type: type)
        } else {
            suggestions.deselect()
        }
    }
    
    func reset() {
        search.reset()
    }
    
    func closeKeyboard() {
        search.closeKeyboard()
    }
    
    func resetSuggestion() {
        suggestions.deselect()
    }
    
    var doneIsHidden: Bool {
        get {
            return topBar.doneIsHidden
        }
        set {
            topBar.doneIsHidden = newValue
        }
    }
    
    // MARK: - search
       
    private func searchUpdated(to searchText: String) {
       bufferCall(with: searchText) { [weak self] (searchText) in
           self?.initiateSearch(searchText)
       }
    }

    private func initiateSearch(_ searchString: String) {
       
       guard searchString.count > 0 else {
           updateSearchResults(to: [])
           return
       }
       
       PlacesSearchService.shared.search(for: searchString) { [weak self] (results) in
           self?.updateSearchResults(to: results)
       }
    }

    private func updateSearchResults(to results: [PlacesSearchService.PlaceData]) {
        searchResults.setup(for: results)
    }
    
    // MARK: - suggestions
    
    private func suggestionSelected(type: MeetType) {
        guard let post = post else { return }
        
        switch type {
        case .destination:
            if let experience = ExperienceTrackingService.shared.getActiveExperiences() .first(where: { $0.id == post.experience.id }),
                let location = experience.destination {
                GeoService.shared.getPlace(for: location.location()) { [weak self] (place, _) in
                    if let place = place {
                        self?.suggestionSelected?(place, .destination)
                    }
                }
            }
        case .halfway:
            if let request = request {
                GeoService.shared.getRequestMeetPoint(request: request) { [weak self] point in
                    GeoService.shared.getPlace(for: point.location()) { [weak self] (place, _) in
                        if let place = place {
                            self?.suggestionSelected?(place, .halfway)
                        }
                    }
                }
            } else {
                GeoService.shared.getPostMeetPoint(post: post) { [weak self] point in
                    GeoService.shared.getPlace(for: point.location()) { [weak self] (place, _) in
                        if let place = place {
                            self?.suggestionSelected?(place, .halfway)
                        }
                    }
                }
            }
        case .near:
            if let location = LocationService.shared.currentLocation {
                GeoService.shared.getPlace(for: location) { [weak self] (place, _) in
                    if let place = place {
                        self?.suggestionSelected?(place, .near)
                    }
                }
            }
        default:
            ()
        }
        
    }

}
