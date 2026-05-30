//
//  CharactersViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 13/05/26.
//

import Foundation
import Combine

final class CharactersViewModel {
    
    // Published
    @Published private(set) var currentCharacters: [CharacterModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: NetworkError? = nil
    
    // Search
    let searchQuery = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()
    
    // Pagination
    private(set) var pagination: PaginationModel?
    private(set) var currentPageIndex: Int = 0
    private(set) var charactersPages: [[CharacterModel]] = []
    
    // Computed Properties
    var isSearching: Bool { !searchQuery.value.isEmpty }
    
    var canGoNext: Bool {
        currentPageIndex < charactersPages.count - 1 || pagination?.next != nil
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
                    self.currentCharacters = self.charactersPages.isEmpty ? [] : self.charactersPages[self.currentPageIndex]
                } else {
                    self.fetchSearchResults(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    
    /// Fetch characters and caches the result.
    func fetchCharacters() {
        guard pagination == nil || pagination?.next != nil else { return }
        
        let pageToFetch = pagination?.next ?? 1
        let characterCache = "characters_page_\(pageToFetch)"
        let paginationCache = "characters_pagination_\(pageToFetch)"
        
        isLoading = true
        
        if let cachedCharacters: [CharacterModel] = cacheManager.get(forKey: characterCache),
            let cachedPagination: PaginationModel = cacheManager.get(forKey: paginationCache) {
            charactersPages.append(cachedCharacters)
            currentPageIndex = self.charactersPages.count - 1
            pagination = cachedPagination
            currentCharacters = cachedCharacters
            isLoading = false
            return
        }
        
        potterService.getCharacters(page: String(pageToFetch)) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.charactersPages.append(response.data)
                self.currentPageIndex = self.charactersPages.count - 1
                self.pagination = response.meta.pagination
                self.currentCharacters = response.data
                
                cacheManager.set(self.charactersPages[currentPageIndex], forKey: characterCache)
                cacheManager.set(self.pagination, forKey: paginationCache)
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    
    /// Fetch characters by name.
    /// - Parameter query: Character name.
    private func fetchSearchResults(query: String) {
        isLoading = true
        
        potterService.getCharactersByName(name: query) { [weak self] result in
            guard let self = self else { return }
            isLoading = false
            
            switch result {
            case .success(let response):
                self.currentCharacters = response.data
            case .failure(let error):
                self.error = error
                self.currentCharacters = []
            }
        }
    }
    
    
    /// Go to next page.
    func nextPage() {
        guard !isSearching else { return }
        if currentPageIndex < charactersPages.count - 1 {
            currentPageIndex += 1
            currentCharacters = charactersPages[currentPageIndex]
        } else {
            fetchCharacters()
        }
    }
    
    
    /// Go to previous page.
    func prevPage() {
        guard canGoPrev else { return }
        currentPageIndex -= 1
        currentCharacters = charactersPages[currentPageIndex]
    }
    
    
    /// Reset variables.
    func reset() {
        charactersPages = []
        pagination = nil
        currentPageIndex = 0
        currentCharacters = []
    }
}
