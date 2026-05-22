//
//  SpellsViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 13/05/26.
//

import Foundation

final class SpellsViewModel {
    
    var onSpellsUpdated: (() -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onError: ((NetworkError) -> Void)?
    
    private(set) var pagination: PaginationModel?
    
    // Pagination with an array, contains 100 items each.
    private(set) var currentPageIndex: Int = 0
    private(set) var spellsPages: [[SpellModel]] = []
    
    // Returns current index array or search result
    var currentSpells: [SpellModel] {
        if isSearching {
            return searchResults
        }
        guard !spellsPages.isEmpty else { return [] }
        return spellsPages[currentPageIndex]
    }
    
    var canGoNext: Bool {
        currentPageIndex < spellsPages.count - 1 || pagination?.next != nil
    }
    
    var canGoPrev: Bool {
        currentPageIndex > 0
    }
    
    private(set) var isSearching: Bool = false
    private(set) var searchResults: [SpellModel] = []
    private var searchTask: DispatchWorkItem?
    
    private let potterService: PotterServiceProtocol
    private let cacheManager: CacheManager
    
    init(potterService: PotterServiceProtocol, cacheManager: CacheManager) {
        self.potterService = potterService
        self.cacheManager = cacheManager
    }
    
    
    /// Fetch spells and caches the result.
    func fetchSpells() {
        guard pagination == nil || pagination?.next != nil else { return }
        
        let pageToFetch = pagination?.next ?? 1
        let spellsCache = "spells_page_\(pageToFetch)"
        let paginationCache = "spells_pagination_\(pageToFetch)"
        
        onLoading?(true)
        
        if let spellsCache: [SpellModel] = cacheManager.get(forKey: spellsCache),
           let paginationCache: PaginationModel = cacheManager.get(forKey: paginationCache) {
            self.spellsPages.append(spellsCache)
            self.currentPageIndex = self.spellsPages.count - 1
            self.pagination = paginationCache
            self.onSpellsUpdated?()
            self.onLoading?(false)
            return
        }
        
        potterService.getSpells(page: String(pageToFetch)) { [weak self] result in
            guard let self = self else { return }
            
            onLoading?(false)
            
            switch result {
            case .success(let response):
                self.spellsPages.append(response.data)
                self.currentPageIndex = self.spellsPages.count - 1
                self.pagination = response.meta.pagination
                
                self.onSpellsUpdated?()
                
                cacheManager.set(self.spellsPages[currentPageIndex], forKey: spellsCache)
                cacheManager.set(self.pagination, forKey: paginationCache)
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    
    /// Search spells by name. Fires `fetchSearchResult` function.
    /// - Parameter query: Spell name.
    func search(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            isSearching = false
            searchResults = []
            onSpellsUpdated?()
            return
        }
        
        isSearching = true
        
        let task = DispatchWorkItem { [weak self] in
            self?.fetchSearchResults(query: query)
        }
        
        searchTask = task
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: task)
    }
    
    
    /// Fetch spells by name.
    /// - Parameter query: Spell name.
    private func fetchSearchResults(query: String) {
        onLoading?(true)
        
        potterService.getSpellsByName(name: query) { [weak self] result in
            guard let self = self else { return }
            
            self.onLoading?(false)
            
            switch result {
            case .success(let response):
                self.searchResults = response.data
                self.onSpellsUpdated?()
            case .failure(let error):
                self.onError?(error)
                onSpellsUpdated?()
            }
        }
    }
    
    
    /// Go to next page.
    func nextPage() {
        guard !isSearching else { return }
        if currentPageIndex < spellsPages.count - 1 {
            currentPageIndex += 1
            onSpellsUpdated?()
        } else {
            fetchSpells()
        }
    }
    
    
    /// Go to previous page.
    func prevPage() {
        guard canGoPrev else { return }
        currentPageIndex -= 1
        onSpellsUpdated?()
    }
    
    
    /// Reset variables.
    func reset() {
        spellsPages = []
        pagination = nil
        currentPageIndex = 0
    }
}
