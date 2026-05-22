//
//  BooksViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

final class BooksViewModel {
    
    var onLoading: ((Bool) -> Void)?
    var onBooksUpdated: (() -> Void)?
    var onChaptersUpdated: (() -> Void)?
    var onError: ((NetworkError) -> Void)?
    
    private(set) var books: [BookModel] = [] {
        didSet {
            self.onBooksUpdated?()
        }
    }
    
    private(set) var chapters: [ChapterModel] = [] {
        didSet {
            self.onChaptersUpdated?()
        }
    }
    
    private let potterService: PotterServiceProtocol
    private let cacheManager: CacheManager
    
    init(potterService: PotterServiceProtocol, cacheManager: CacheManager) {
        self.potterService = potterService
        self.cacheManager = cacheManager
    }
    
    
    /// Fetch books and caches the result.
    func fetchBooks() {
        let cacheKey = "books"
        
        onLoading?(true)
        
        if let cached: [BookModel] = cacheManager.get(forKey: cacheKey) {
            self.books = cached
            self.onLoading?(false)
            return
        }
        
        potterService.getBooks { [weak self] result in
            guard let self = self else { return }
            
            self.onLoading?(false)
            
            switch result {
            case .success(let response):
                self.books = response.data
                cacheManager.set(self.books, forKey: cacheKey, expiry: .hours(24))
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    
    /// Fetch chapters for book ID and caches the result.
    /// - Parameter bookID: Chapter's book ID.
    func fetchChapters(bookID: String) {
        let cacheKey = "chapter_\(bookID)"
        
        onLoading?(true)
        
        if let cached: [ChapterModel] = cacheManager.get(forKey: cacheKey) {
            self.chapters = cached
            self.onLoading?(false)
            return
        }
        
        potterService.getChapters(bookID: bookID) { [weak self] result in
            guard let self = self else { return }
            
            self.onLoading?(false)
            
            switch result {
            case .success(let response):
                self.chapters = response.data
                cacheManager.set(self.chapters, forKey: cacheKey, expiry: .hours(24))
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
}
