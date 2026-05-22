//
//  SpellsResponse.swift
//  PotterWiki
//
//  Created by Ziqa on 21/05/26.
//

import Foundation

struct SpellsResponse: Codable {
    let data: [SpellModel]
    let meta: MetaModel
}

struct SpellModel: Identifiable, Codable, Hashable {
    let id: String
    let attributes: SpellAttributes
}

struct SpellAttributes: Codable, Hashable {
    let slug: String?
    let category: String?
    let creator: String?
    let effect: String?
    let hand: String?
    let image: String?
    let incantation: String?
    let light: String?
    let name: String?
    let wiki: String?

    enum CodingKeys: String, CodingKey {
        case slug
        case category
        case creator
        case effect
        case hand
        case image
        case incantation
        case light
        case name
        case wiki
    }
}
