//
//  PotionsViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 13/05/26.
//

import Foundation
import Combine

final class PotionsViewModel {
    
    // Published
    @Published private(set) var currentPotions: [PotionModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: NetworkError? = nil
    
    // Pagination
    private(set) var pagination: PaginationModel?
    private(set) var currentPageIndex: Int = 0
    private(set) var potionsPages: [[PotionModel]] = []
    
    // Search
    let searchQuery = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()
    
    // Computed Properties
    var isSearching: Bool { !searchQuery.value.isEmpty }
    
    var canGoNext: Bool {
        currentPageIndex < potionsPages.count - 1 || pagination?.next != nil
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
                    self.currentPotions = self.currentPotions.isEmpty ? [] : self.potionsPages[self.currentPageIndex]
                } else {
                    fetchSearchResults(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Fetch potions and caches the result.
    func fetchPotions() {
        guard pagination == nil || pagination?.next != nil else { return }
        
        let pageToFetch = pagination?.next ?? 1
        let potionsCache = "potions_page_\(pageToFetch)"
        let paginationCache = "potions_pagination_\(pageToFetch)"
        
        isLoading = true
        
        if let cachedPotions: [PotionModel] = cacheManager.get(forKey: potionsCache),
            let cachedPagination: PaginationModel = cacheManager.get(forKey: paginationCache) {
            potionsPages.append(cachedPotions)
            currentPageIndex = potionsPages.count - 1
            pagination = cachedPagination
            currentPotions = cachedPotions
            isLoading = false
            return
        }
        
        potterService.getPotions(page: String(pageToFetch)) { [weak self] result in
            guard let self = self else { return }
            isLoading = false
            
            switch result {
            case .success(let response):
                self.potionsPages.append(response.data)
                self.currentPageIndex = self.potionsPages.count - 1
                self.pagination = response.meta.pagination
                self.currentPotions = response.data
                
                cacheManager.set(self.potionsPages[currentPageIndex], forKey: potionsCache)
                cacheManager.set(self.pagination, forKey: paginationCache)
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    
    /// Fetch potions by name.
    /// - Parameter query: Potion name.
    private func fetchSearchResults(query: String) {
        isLoading = true
        
        potterService.getPotionsByName(name: query) { [weak self] result in
            guard let self = self else { return }
            isLoading = false
            
            switch result {
            case .success(let response):
                self.currentPotions = response.data
            case .failure(let error):
                self.error = error
                self.currentPotions = []
            }
        }
    }
    
    
    /// Go to next page.
    func nextPage() {
        guard !isSearching else { return }
        if currentPageIndex < potionsPages.count - 1 {
            currentPageIndex += 1
            currentPotions = potionsPages[currentPageIndex]
        } else {
            fetchPotions()
        }
    }
    
    
    /// Go to previous page.
    func prevPage() {
        guard canGoPrev else { return }
        currentPageIndex -= 1
        currentPotions = potionsPages[currentPageIndex]
    }
    
    
    /// Reset variables.
    func reset() {
        potionsPages = []
        pagination = nil
        currentPageIndex = 0
        currentPotions = []
    }
}
