//
//  BooksResponse.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

struct BooksResponse: Codable {
    let data: [BookModel]
    let meta: MetaModel
}

struct BookModel: Identifiable, Codable, nonisolated Hashable {
    let id: String
    let attributes: BookAttributes
}

struct BookAttributes: Codable, nonisolated Hashable {
    let author: String
    let cover: String
    let pages: Int
    let releaseDate: String
    let summary: String
    let title: String
    let wiki: String
    
    enum CodingKeys: String, CodingKey {
        case author, cover, pages, summary, title, wiki
        case releaseDate = "release_date"
    }
}


// MARK: - Sample Data
extension BooksResponse {
    static let sampleResponse = BooksResponse(
        data: BookModel.sampleBook,
        meta: MetaModel.sampleMeta
    )
}

extension BookModel {
    static let sampleBook = [
        BookModel(id: "76040954-a2ea-45bc-a058-6d2d9f6d71ea", attributes: BookAttributes.sampleAttribute),
        BookModel(id: "76040954-a2ea-45bc-a058-6d2d9f6d71ea", attributes: BookAttributes.sampleAttribute),
    ]
}

extension BookAttributes {
    static let sampleAttribute = BookAttributes(
        author: "J.K. Rowling",
        cover: "https://www.wizardingworld.com/images/products/books/UK/rectangle-1.jpg",
        pages: 223,
        releaseDate: "1997-06-26",
        summary: "Harry Potter has never even heard of Hogwarts when the letters start dropping on the doormat at number four, Privet Drive. Addressed in green ink on yellowish parchment with a purple seal, they are swiftly confiscated by his grisly aunt and uncle. Then, on Harry's eleventh birthday, a great beetle-eyed giant of a man called Rubeus Hagrid bursts in with some astonishing news: Harry Potter is a wizard, and he has a place at Hogwarts School of Witchcraft and Wizardry. An incredible adventure is about to begin!",
        title: "Harry Potter and the Philosopher's Stone",
        wiki: "https://harrypotter.fandom.com/wiki/Harry_Potter_and_the_Philosopher's_Stone"
    )
}
