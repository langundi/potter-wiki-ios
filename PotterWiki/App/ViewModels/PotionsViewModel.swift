//
//  PotionsViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 13/05/26.
//

import Foundation

final class PotionsViewModel {
    
    var onPotionsUpdated: (() -> Void)?
    var onLoading: ((Bool) -> Void)?
    var onError: ((NetworkError) -> Void)?
    
    private(set) var pagination: PaginationModel?
    
    // Pagination with an array, contains 100 items each.
    private(set) var currentPageIndex: Int = 0
    private(set) var potionsPages: [[PotionModel]] = []
    
    // Returns current index array or search result
    var currentPotions: [PotionModel] {
        if isSearching {
            return searchResults
        }
        guard !potionsPages.isEmpty else { return [] }
        return potionsPages[currentPageIndex]
    }
    
    var canGoNext: Bool {
        currentPageIndex < potionsPages.count - 1 || pagination?.next != nil
    }
    
    var canGoPrev: Bool {
        currentPageIndex > 0
    }
    
    private(set) var isSearching: Bool = false
    private(set) var searchResults: [PotionModel] = []
    private var searchTask: DispatchWorkItem?
    
    private let potterService: PotterServiceProtocol
    private let cacheManager: CacheManager
    
    init(potterService: PotterServiceProtocol, cacheManager: CacheManager) {
        self.potterService = potterService
        self.cacheManager = cacheManager
    }
    
    
    /// Fetch potions and caches the result.
    func fetchPotions() {
        guard pagination == nil || pagination?.next != nil else { return }
        
        let pageToFetch = pagination?.next ?? 1
        let potionsCache = "potions_page_\(pageToFetch)"
        let paginationCache = "potions_pagination_\(pageToFetch)"
        
        onLoading?(true)
        
        if let potionsCache: [PotionModel] = cacheManager.get(forKey: potionsCache),
           let paginationCache: PaginationModel = cacheManager.get(forKey: paginationCache) {
            self.potionsPages.append(potionsCache)
            self.currentPageIndex = self.potionsPages.count - 1
            self.pagination = paginationCache
            self.onPotionsUpdated?()
            self.onLoading?(false)
            return
        }
        
        potterService.getPotions(page: String(pageToFetch)) { [weak self] result in
            guard let self = self else { return }
            
            onLoading?(false)
            
            switch result {
            case .success(let response):
                self.potionsPages.append(response.data)
                self.currentPageIndex = self.potionsPages.count - 1
                self.pagination = response.meta.pagination
                
                self.onPotionsUpdated?()
                
                cacheManager.set(self.potionsPages[currentPageIndex], forKey: potionsCache)
                cacheManager.set(self.pagination, forKey: paginationCache)
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    
    /// Search potions by name. Fires `fetchSearchResult` function.
    /// - Parameter query: Potion name.
    func search(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            isSearching = false
            searchResults = []
            onPotionsUpdated?()
            return
        }
        
        isSearching = true
        
        let task = DispatchWorkItem { [weak self] in
            self?.fetchSearchResults(query: query)
        }
        
        searchTask = task
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: task)
    }
    
    
    /// Fetch potions by name.
    /// - Parameter query: Potion name.
    private func fetchSearchResults(query: String) {
        onLoading?(true)
        
        potterService.getPotionsByName(name: query) { [weak self] result in
            guard let self = self else { return }
            
            self.onLoading?(false)
            
            switch result {
            case .success(let response):
                self.searchResults = response.data
                self.onPotionsUpdated?()
            case .failure(let error):
                self.onError?(error)
                onPotionsUpdated?()
            }
        }
    }
    
    
    /// Go to next page.
    func nextPage() {
        guard !isSearching else { return }
        if currentPageIndex < potionsPages.count - 1 {
            currentPageIndex += 1
            onPotionsUpdated?()
        } else {
            fetchPotions()
        }
    }
    
    
    /// Go to previous page.
    func prevPage() {
        guard canGoPrev else { return }
        currentPageIndex -= 1
        onPotionsUpdated?()
    }
    
    
    /// Reset variables.
    func reset() {
        potionsPages = []
        pagination = nil
        currentPageIndex = 0
    }
}
