//
//  BookChapters.swift
//  PotterWiki
//
//  Created by Ziqa on 16/05/26.
//

import Foundation

struct ChaptersResponse: Codable {
    let data: [ChapterModel]
}

struct ChapterModel: Identifiable, Codable {
    let id: String
    let attributes: ChapterAttributes
}

struct ChapterAttributes: Codable {
    let order: Int
    let summary: String?
    let title: String
}

// MARK: - Sample Data
extension ChaptersResponse {
    static let sampleResponse = ChaptersResponse(data: ChapterModel.sampleChapter)
}

extension ChapterModel {
    static let sampleChapter = [
        ChapterModel(id: UUID().uuidString, attributes: ChapterAttributes.sampleAttribute),
        ChapterModel(id: UUID().uuidString, attributes: ChapterAttributes.sampleAttribute),
    ]
}

extension ChapterAttributes {
    static let sampleAttribute = ChapterAttributes(
        order: 1,
        summary: "The lazy fox jumps over the brown dog.",
        title: "Absolute Cinema"
    )
}

