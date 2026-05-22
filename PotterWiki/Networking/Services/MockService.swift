//
//  MockService.swift
//  PotterWiki
//
//  Created by Ziqa on 22/05/26.
//

import Foundation

final class MockService: PotterServiceProtocol {
    
    var getBooksResult: Result<BooksResponse, NetworkError> = .success(.sampleResponse) // Returns sample books
    
    var getChaptersResult: Result<ChaptersResponse, NetworkError> = .success(.sampleResponse) // Returns sample chapters
    
    var getMoviesResult: Result<MoviesResponse, NetworkError> = .success(.sampleResponse) // Returns sample movies
    
    var getCharactersResult: Result<CharactersResponse, NetworkError> = .failure(.noDataRecieved)
    
    var getCharactersByNameResult: Result<CharactersResponse, NetworkError> = .failure(.noDataRecieved)
    
    var getPotionsResult: Result<PotionsResponse, NetworkError> = .failure(.noDataRecieved)
    
    var getPotionsByNameResult: Result<PotionsResponse, NetworkError> = .failure(.noDataRecieved)
    
    var getSpellsResult: Result<SpellsResponse, NetworkError> = .failure(.noDataRecieved)
    
    var getSpellsByNameResult: Result<SpellsResponse, NetworkError> = .failure(.noDataRecieved)
    
    
    func getBooks(completion: @escaping (Result<BooksResponse, NetworkError>) -> Void) {
        completion(getBooksResult)
    }
    
    func getChapters(bookID: String, completion: @escaping (Result<ChaptersResponse, NetworkError>) -> Void) {
        completion(getChaptersResult)
    }
    
    func getMovies(completion: @escaping (Result<MoviesResponse, NetworkError>) -> Void) {
        completion(getMoviesResult)
    }
    
    func getCharacters(page: String, completion: @escaping (Result<CharactersResponse, NetworkError>) -> Void) {
        completion(getCharactersResult)
    }
    
    func getCharactersByName(name: String, completion: @escaping (Result<CharactersResponse, NetworkError>) -> Void) {
        completion(getCharactersByNameResult)
    }
    
    func getPotions(page: String, completion: @escaping (Result<PotionsResponse, NetworkError>) -> Void) {
        completion(getPotionsResult)
    }
    
    func getPotionsByName(name: String, completion: @escaping (Result<PotionsResponse, NetworkError>) -> Void) {
        completion(getPotionsByNameResult)
    }
    
    func getSpells(page: String, completion: @escaping (Result<SpellsResponse, NetworkError>) -> Void) {
        completion(getSpellsResult)
    }
    
    func getSpellsByName(name: String, completion: @escaping (Result<SpellsResponse, NetworkError>) -> Void) {
        completion(getSpellsByNameResult)
    }
    
}
