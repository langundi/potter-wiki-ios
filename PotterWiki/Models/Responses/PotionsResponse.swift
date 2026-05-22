//
//  PotionsResponse.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

struct PotionsResponse: Codable {
    let data: [PotionModel]
    let meta: MetaModel
}

struct PotionModel: Identifiable, Codable, Hashable {
    let id: String
    let attributes: PotionAttributes
}

struct PotionAttributes: Codable, Hashable {
    let slug: String?
    let characteristics: String?
    let difficulty: String?
    let effect: String?
    let image: String?
    let inventors: String?
    let ingredients: String?
    let manufacturers: String?
    let name: String?
    let sideEffects: String?
    let time: String?
    let wiki: String?
    
    enum CodingKeys: String, CodingKey {
        case slug
        case characteristics
        case difficulty
        case effect
        case image
        case inventors
        case ingredients
        case manufacturers
        case name
        case sideEffects = "side_effects"
        case time
        case wiki
    }
}
