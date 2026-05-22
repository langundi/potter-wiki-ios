//
//  PotterServiceProtocol.swift
//  PotterWiki
//
//  Created by Ziqa on 22/05/26.
//

import Foundation

protocol PotterServiceProtocol {
    
    func getBooks(completion: @escaping (Result<BooksResponse, NetworkError>) -> Void)
    
    func getChapters(bookID: String, completion: @escaping (Result<ChaptersResponse, NetworkError>) -> Void)
    
    func getMovies(completion: @escaping (Result<MoviesResponse, NetworkError>) -> Void)
    
    func getCharacters(page: String, completion: @escaping (Result<CharactersResponse, NetworkError>) -> Void)
    
    func getCharactersByName(name: String, completion: @escaping (Result<CharactersResponse, NetworkError>) -> Void)
    
    func getPotions(page: String, completion: @escaping (Result<PotionsResponse, NetworkError>) -> Void)
    
    func getPotionsByName(name: String, completion: @escaping (Result<PotionsResponse, NetworkError>) -> Void)
    
    func getSpells(page: String, completion: @escaping (Result<SpellsResponse, NetworkError>) -> Void)
    
    func getSpellsByName(name: String, completion: @escaping (Result<SpellsResponse, NetworkError>) -> Void)
    
}
