//
//  CharactersResponse.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

struct CharactersResponse: Codable {
    let data: [CharacterModel]
    let meta: MetaModel
}

struct CharacterModel: Identifiable, Codable, nonisolated Hashable, Sendable {
    let id: String
    let attributes: CharacterAttributes
}

struct CharacterAttributes: Codable, nonisolated Hashable {
    let slug: String?
    let aliasNames: [String]?
    let animagus: String?
    let bloodStatus: String?
    let boggart: String?
    let born: String?
    let died: String?
    let eyeColor: String?
    let familyMembers: [String]?
    let gender: String?
    let hairColor: String?
    let height: String?
    let house: String?
    let image: String?
    let jobs: [String]?
    let maritalStatus: String?
    let name: String?
    let nationality: String?
    let patronus: String?
    let romances: [String]?
    let skinColor: String?
    let species: String?
    let titles: [String]?
    let wands: [String]?
    let weight: String?
    let wiki: String?
    
    enum CodingKeys: String, CodingKey {
        case slug
        case aliasNames = "alias_names"
        case animagus
        case bloodStatus = "blood_status"
        case boggart
        case born
        case died
        case eyeColor = "eye_color"
        case familyMembers = "family_members"
        case gender
        case hairColor = "hair_color"
        case height
        case house
        case image
        case jobs
        case maritalStatus = "marital_status"
        case name
        case nationality
        case patronus
        case romances
        case skinColor = "skin_color"
        case species
        case titles
        case wands
        case weight
        case wiki
    }
}
