//
//  CreateSignalPlaceSearchPanel.swift
//  More
//
//  Created by Luko Gjenero on 10/10/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class CreateSignalPlaceSearchPanel: LoadableView, BufferedRunInterface {

    typealias BufferedData = String
    var buffer: String?
    var bufferDelay: TimeInterval {
        return 0.5
    }
    var bufferTimer: Timer?

    @IBOutlet private weak var topBar: CreateSignalPlaceSearchPanelTopBar!
    @IBOutlet private weak var search: CreateSignalPlaceSearchView!
    @IBOutlet private weak var suggestionsLabel: UILabel!
    @IBOutlet private weak var suggestions: CreateSignalPlaceSuggestionView!
    @IBOutlet private weak var searchResults: CreateSignalPlaceSearchResultView!
    
    var backTap: (()->())?
    var doneTap: (()->())?
    var searchFocus: ((_ inFocus: Bool)->())?
    var placeSelected: ((_ place: PlacesSearchService.PlaceData)->())?
    var suggestionSelected: ((_ suggestion: ExperiencePlaceSuggestion)->())?
    
    override func setupNib() {
        super.setupNib()

        suggestionsLabel.isHidden = false
        suggestions.isHidden = false
        searchResults.isHidden = true
        topBar.doneIsHidden = true
        
        topBar.backTap = { [weak self] in
            self?.backTap?()
        }
        
        topBar.doneTap = { [weak self] in
            self?.doneTap?()
        }
        
        search.searchChanged = { [weak self] text in
            self?.searchUpdated(to: text ?? "")
        }
        
        search.searchFocus = { [weak self] inFocus in
            
            self?.suggestionsLabel.isHidden = inFocus
            self?.suggestions.isHidden = inFocus
            self?.searchResults.isHidden = !inFocus
            
            self?.searchFocus?(inFocus)
        }
        
        searchResults.selected = { [weak self] place in
            self?.placeSelected?(place)
        }
        
        suggestions.selected = { [weak self] suggestion in
            self?.suggestionSelected?(suggestion)
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
    
    var doneIsHidden: Bool {
        get {
            return topBar.doneIsHidden
        }
        set{
            topBar.doneIsHidden = newValue
        }
    }

}
