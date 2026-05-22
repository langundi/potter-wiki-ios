//
//  MetaModel.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

struct MetaModel: Codable {
    let pagination: PaginationModel
}

struct PaginationModel: Codable {
    let current: Int
    let first: Int?
    let prev: Int?
    let next: Int?
    let last: Int?
    let records: Int
}

extension MetaModel {
    static let sampleMeta = MetaModel(
        pagination: PaginationModel(
            current: 1,
            first: 1,
            prev: nil,
            next: nil,
            last: 1,
            records: 2
        )
    )
}
