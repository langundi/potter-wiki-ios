//
//  BooksViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation
import Combine

final class BooksViewModel {
    
    @Published private(set) var books: [BookModel] = []
    @Published private(set) var chapters: [ChapterModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: NetworkError? = nil
    
    private let potterService: PotterServiceProtocol
    private let cacheManager: CacheManager
    
    init(potterService: PotterServiceProtocol, cacheManager: CacheManager) {
        self.potterService = potterService
        self.cacheManager = cacheManager
    }
    
    
    /// Fetch books and caches the result.
    func fetchBooks() {
        let cacheKey = "books"
        
        isLoading = true
        
        if let cached: [BookModel] = cacheManager.get(forKey: cacheKey) {
            books = cached
            isLoading = false
            return
        }
        
        potterService.getBooks { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.books = response.data
                cacheManager.set(self.books, forKey: cacheKey, expiry: .hours(24))
            case .failure(let error):
                self.error = error
                self.books = []
            }
        }
    }
    
    
    /// Fetch chapters for book ID and caches the result.
    /// - Parameter bookID: Chapter's book ID.
    func fetchChapters(bookID: String) {
        let cacheKey = "chapter_\(bookID)"
        isLoading = true
        
        if let cached: [ChapterModel] = cacheManager.get(forKey: cacheKey) {
            chapters = cached
            isLoading = false
            return
        }
        
        potterService.getChapters(bookID: bookID) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.chapters = response.data
                cacheManager.set(self.chapters, forKey: cacheKey, expiry: .hours(24))
            case .failure(let error):
                self.error = error
                self.chapters = []
            }
        }
    }
}
