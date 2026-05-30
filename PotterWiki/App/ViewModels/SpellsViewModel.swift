//
//  SpellsViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 13/05/26.
//

import Foundation
import Combine

final class SpellsViewModel {
    
    // Published
    @Published private(set) var currentSpells: [SpellModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: NetworkError? = nil
    
    // Pagination
    private(set) var pagination: PaginationModel?
    private(set) var currentPageIndex: Int = 0
    private(set) var spellsPages: [[SpellModel]] = []
    
    // Search
    let searchQuery = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()
    
    // Computed Properties
    var isSearching: Bool { !searchQuery.value.isEmpty }
    
    var canGoNext: Bool {
        currentPageIndex < spellsPages.count - 1 || pagination?.next != nil
    }
    
    var canGoPrev: Bool {
        currentPageIndex > 0
    }
    
    // Dependencies
    private let potterService: PotterServiceProtocol
    private let cacheManager: CacheManager
    
    init(potterService: PotterServiceProtocol, cacheManager: CacheManager) {
        self.potterService = potterService
        self.cacheManager = cacheManager
        
        bindSearch()
    }
    
    private func bindSearch() {
        searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global())
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    self.currentSpells = self.currentSpells.isEmpty ? [] : self.spellsPages[self.currentPageIndex]
                } else {
                    fetchSearchResults(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    
    /// Fetch spells and caches the result.
    func fetchSpells() {
        guard pagination == nil || pagination?.next != nil else { return }
        
        let pageToFetch = pagination?.next ?? 1
        let spellsCache = "spells_page_\(pageToFetch)"
        let paginationCache = "spells_pagination_\(pageToFetch)"
        
        isLoading = true
        
        if let cachedSpells: [SpellModel] = cacheManager.get(forKey: spellsCache),
           let cachedPagination: PaginationModel = cacheManager.get(forKey: paginationCache) {
            spellsPages.append(cachedSpells)
            currentPageIndex = self.spellsPages.count - 1
            pagination = cachedPagination
            currentSpells = cachedSpells
            isLoading = false
            return
        }
        
        potterService.getSpells(page: String(pageToFetch)) { [weak self] result in
            guard let self = self else { return }
            isLoading = false
            
            switch result {
            case .success(let response):
                self.spellsPages.append(response.data)
                self.currentPageIndex = self.spellsPages.count - 1
                self.pagination = response.meta.pagination
                self.currentSpells = response.data
                
                cacheManager.set(self.spellsPages[currentPageIndex], forKey: spellsCache)
                cacheManager.set(self.pagination, forKey: paginationCache)
            case .failure(let error):
                self.error = error
            }
        }
    }

    
    /// Fetch spells by name.
    /// - Parameter query: Spell name.
    private func fetchSearchResults(query: String) {
        isLoading = true
        
        potterService.getSpellsByName(name: query) { [weak self] result in
            guard let self = self else { return }
            isLoading = false
            
            switch result {
            case .success(let response):
                self.currentSpells = response.data
            case .failure(let error):
                self.error = error
                self.currentSpells = []
            }
        }
    }
    
    
    /// Go to next page.
    func nextPage() {
        guard !isSearching else { return }
        if currentPageIndex < spellsPages.count - 1 {
            currentPageIndex += 1
            currentSpells = spellsPages[currentPageIndex]
        } else {
            fetchSpells()
        }
    }
    
    
    /// Go to previous page.
    func prevPage() {
        guard canGoPrev else { return }
        currentPageIndex -= 1
        currentSpells = spellsPages[currentPageIndex]
    }
    
    
    /// Reset variables.
    func reset() {
        spellsPages = []
        pagination = nil
        currentPageIndex = 0
        currentSpells = []
    }
}
