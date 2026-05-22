//
//  PotterService.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

final class PotterService: PotterServiceProtocol {
    
    init() { }
    
    /// Make a request to endpoint.
    /// - Parameters:
    ///   - endpoint: endpoint type.
    ///   - completion: returns a callback for response and error.
    private func request<T:Codable>(endpoint: EndpointType, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.noInternet))
            return
        }
        
        guard let url = URL(string: endpoint.fullURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestError(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200..<299).contains(response.statusCode) else {
                completion(.failure(.responseError))
                return
            }
            
            
            guard let data = data else {
                completion(.failure(.noDataRecieved))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch let decodingError as DecodingError {
                completion(.failure(.decodingError(decodingError)))
            } catch {
                completion(.failure(.parsingError))
            }
        }
        task.resume()
    }

    
    /// Fetch books.
    /// - Parameter completion: Returns books.
    func getBooks(completion: @escaping (Result<BooksResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getBooks, completion: completion)
    }
    
    
    /// Fetch book's chapters.
    /// - Parameters:
    ///   - bookID: Book ID for chapters.
    ///   - completion: Returns chapters.
    func getChapters(bookID: String, completion: @escaping (Result<ChaptersResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getChapters(bookID: bookID), completion: completion)
    }
    
    
    /// Fetch movies.
    /// - Parameter completion: Returns movies.
    func getMovies(completion: @escaping (Result<MoviesResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getMovies, completion: completion)
    }
    
    
    /// Fetch characters with pagination.
    /// - Parameters:
    ///   - page: Page number.
    ///   - completion: Returns potions.
    func getCharacters(page: String, completion: @escaping (Result<CharactersResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getCharacters(page: page), completion: completion)
    }
    
    
    /// Fetch characters by name.
    /// - Parameters:
    ///   - name: Character name.
    ///   - completion: Returns characters equal to name.
    func getCharactersByName(name: String, completion: @escaping (Result<CharactersResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getCharactersByName(name: name), completion: completion)
    }
    
    
    /// Fetch potions with pagination.
    /// - Parameters:
    ///   - page: Page number.
    ///   - completion: Returns potions.
    func getPotions(page: String, completion: @escaping (Result<PotionsResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getPotions(page: page), completion: completion)
    }
    
    
    /// Fetch potions by name.
    /// - Parameters:
    ///   - name: Potion name.
    ///   - completion: Returns potions equal to name.
    func getPotionsByName(name: String, completion: @escaping (Result<PotionsResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getPotionsByName(name: name), completion: completion)
    }
    
    
    /// Fetch spells with pagination.
    /// - Parameters:
    ///   - page: Page number.
    ///   - completion: Returns spells.
    func getSpells(page: String, completion: @escaping (Result<SpellsResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getSpells(page: page), completion: completion)
    }
    
    
    /// Fetch spells by name.
    /// - Parameters:
    ///   - name: Spell name.
    ///   - completion: Returns spells equal to name.
    func getSpellsByName(name: String, completion: @escaping (Result<SpellsResponse, NetworkError>) -> Void) {
        request(endpoint: Endpoint.getSpellsByName(name: name), completion: completion)
    }
    
}
