//
//  Endpoint.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

protocol EndpointType {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var fullURL: String { get }
}

extension EndpointType {
    var queryItem: [URLQueryItem]? { return nil }
    
    var fullURL: String {
        let base = [baseURL, path]
            .map { $0.trimmingCharacters(in: .init(charactersIn: "/")) }
            .joined(separator: "/")
        
        guard let items = queryItems, !items.isEmpty,
              var components = URLComponents(string: base) else {
            return base
        }
        
        components.queryItems = items
        return components.url?.absoluteString ?? base
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum Endpoint: EndpointType {
    
    case getBooks
    case getChapters(bookID: String)
    case getMovies
    case getCharacters(page: String)
    case getCharactersByName(name: String)
    case getPotions(page: String)
    case getPotionsByName(name: String)
    case getSpells(page: String)
    case getSpellsByName(name: String)
    
    var baseURL: String {
        return Constants.BASE_URL
    }
    
    var path: String {
        switch self {
        case .getBooks:
            return Constants.API_VERSION + "/books"
        case .getChapters(let bookID):
            return Constants.API_VERSION + "/books/\(bookID)/chapters"
        case .getMovies:
            return Constants.API_VERSION + "/movies"
        case .getCharacters, .getCharactersByName:
            return Constants.API_VERSION + "/characters"
        case .getPotions, .getPotionsByName:
            return Constants.API_VERSION + "/potions"
        case .getSpells, .getSpellsByName:
            return Constants.API_VERSION + "/spells"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getCharacters(let page):
            return [URLQueryItem(name: "page[number]", value: page)]
        case .getCharactersByName(let name):
            return [URLQueryItem(name: "filter[name_cont]", value: name)]
        case .getPotions(let page):
            return [URLQueryItem(name: "page[number]", value: page)]
        case .getPotionsByName(let name):
            return [URLQueryItem(name: "filter[name_cont]", value: name)]
        case .getSpells(let page):
            return [URLQueryItem(name: "page[number]", value: page)]
        case .getSpellsByName(let name):
            return [URLQueryItem(name: "filter[name_cont]", value: name)]
        default:
            return nil
        }
    }
    
}
