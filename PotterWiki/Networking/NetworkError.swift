//
//  NetworkError.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

enum NetworkError: Error {
    case noInternet
    case invalidURL
    case requestError(Error)
    case noDataRecieved
    case parsingError
    case decodingError(Error)
    case responseError
    
    var message: String {
        switch self {
        case .noInternet:
            return "No internet connection. Please check your network."
        case .invalidURL:
            return "Invalid URL."
        case .requestError(let error):
            return error.localizedDescription
        case .responseError:
            return "Server error. Please try again."
        case .noDataRecieved:
            return "No data received."
        case .decodingError:
            return "Failed to parse response."
        case .parsingError:
            return "Parsing error."
        }
    }
}
