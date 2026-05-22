//
//  CharactersViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 13/05/26.
//

import Foundation

final class CharactersViewModel {
    
    var onLoading: ((Bool) -> Void)?
    var onCharactersUpdated: (() -> Void)?
    var onError: ((NetworkError) -> Void)?
    
    private(set) var pagination: PaginationModel?
    
    // Pagination with an array, contains 100 items each.
    private(set) var currentPageIndex: Int = 0
    private(set) var charactersPages: [[CharacterModel]] = []
    
    // Returns current index array or search result
    var currentCharacters: [CharacterModel] {
        if isSearching {
            return searchResults
        }
        guard !charactersPages.isEmpty else { return [] }
        return charactersPages[currentPageIndex]
    }
    
    var canGoNext: Bool {
        currentPageIndex < charactersPages.count - 1 || pagination?.next != nil
    }
    
    var canGoPrev: Bool {
        currentPageIndex > 0
    }
    
    private(set) var isSearching: Bool = false
    private(set) var searchResults: [CharacterModel] = []
    private var searchTask: DispatchWorkItem?
    
    private let potterService: PotterServiceProtocol
    private let cacheManager: CacheManager
    
    init(potterService: PotterServiceProtocol, cacheManager: CacheManager) {
        self.potterService = potterService
        self.cacheManager = cacheManager
    }
    
    
    /// Fetch characters and caches the result.
    func fetchCharacters() {
        guard pagination == nil || pagination?.next != nil else { return }
        
        let pageToFetch = pagination?.next ?? 1
        let characterCache = "characters_page_\(pageToFetch)"
        let paginationCache = "characters_pagination_\(pageToFetch)"
        
        onLoading?(true)
        
        if let characterCache: [CharacterModel] = cacheManager.get(forKey: characterCache),
           let paginationCache: PaginationModel = cacheManager.get(forKey: paginationCache) {
            self.charactersPages.append(characterCache)
            self.currentPageIndex = self.charactersPages.count - 1
            self.pagination = paginationCache
            self.onCharactersUpdated?()
            self.onLoading?(false)
            return
        }
        
        potterService.getCharacters(page: String(pageToFetch)) { [weak self] result in
            guard let self = self else { return }
            
            onLoading?(false)
            
            switch result {
            case .success(let response):
                self.charactersPages.append(response.data)
                self.currentPageIndex = self.charactersPages.count - 1
                self.pagination = response.meta.pagination
                self.onCharactersUpdated?()
                
                cacheManager.set(self.charactersPages[currentPageIndex], forKey: characterCache)
                cacheManager.set(self.pagination, forKey: paginationCache)
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    
    /// Search characters by name. Fires `fetchSearchResult` function.
    /// - Parameter query: Character name.
    func search(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            isSearching = false
            searchResults = []
            onCharactersUpdated?()
            return
        }
        
        isSearching = true
        
        let task = DispatchWorkItem { [weak self] in
            self?.fetchSearchResults(query: query)
        }
        
        searchTask = task
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: task)
    }
    
    
    /// Fetch characters by name.
    /// - Parameter query: Character name.
    private func fetchSearchResults(query: String) {
        onLoading?(true)
        
        potterService.getCharactersByName(name: query) { [weak self] result in
            guard let self = self else { return }
            
            self.onLoading?(false)
            
            switch result {
            case .success(let response):
                self.searchResults = response.data
                self.onCharactersUpdated?()
            case .failure(let error):
                self.onError?(error)
                self.onCharactersUpdated?()
            }
        }
    }
    
    
    /// Go to next page.
    func nextPage() {
        guard !isSearching else { return }
        if currentPageIndex < charactersPages.count - 1 {
            currentPageIndex += 1
            onCharactersUpdated?()
        } else {
            fetchCharacters()
        }
    }
    
    
    /// Go to previous page.
    func prevPage() {
        guard canGoPrev else { return }
        currentPageIndex -= 1
        onCharactersUpdated?()
    }
    
    
    /// Reset variables.
    func reset() {
        charactersPages = []
        pagination = nil
        currentPageIndex = 0
    }
}
