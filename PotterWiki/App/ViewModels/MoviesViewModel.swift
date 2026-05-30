//
//  MoviesViewModel.swift
//  PotterWiki
//
//  Created by Ziqa on 13/05/26.
//

import Foundation
import Combine

final class MoviesViewModel {
    
//    var onLoading: ((Bool) -> Void)?
//    var onMoviesUpdated: (() -> Void)?
//    var onError: ((NetworkError) -> Void)?
    
    @Published private(set) var movies: [MovieModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: NetworkError? = nil
    
//    private(set) var movies: [MovieModel] = [] {
//        didSet {
//            self.onMoviesUpdated?()
//        }
//    }
    
    
    private let potterService: PotterServiceProtocol
    private let cacheManager: CacheManager
    
    init(potterService: PotterServiceProtocol, cacheManager: CacheManager) {
        self.potterService = potterService
        self.cacheManager = cacheManager
    }
    
    
    /// Fetch movies and caches the result.
    func fetchMovies() {
        let cacheKey = "movies"
        isLoading = true
        
        if let cached: [MovieModel] = cacheManager.get(forKey: cacheKey) {
            movies = cached
            isLoading = false
            return
        }
        
        potterService.getMovies { [weak self] result in
            guard let self = self else { return }
            isLoading = true
            
            switch result {
            case .success(let response):
                self.movies = response.data
                cacheManager.set(self.movies, forKey: cacheKey)
            case .failure(let error):
                self.error = error
            }
        }
    }
}
