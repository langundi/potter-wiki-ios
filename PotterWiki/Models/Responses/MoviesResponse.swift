//
//  MoviesResponse.swift
//  PotterWiki
//
//  Created by Ziqa on 11/05/26.
//

import Foundation

struct MoviesResponse: Codable {
    let data: [MovieModel]
    let meta: MetaModel
}

struct MovieModel: Identifiable, Codable, nonisolated Hashable {
    let id: String
    let attributes: MovieAttributes
}

struct MovieAttributes: Codable, nonisolated Hashable {
    let boxOffice: String
    let budget: String
    let cinematographers: [String]
    let directors: [String]
    let distributors: [String]
    let editors: [String]
    let musicComposers: [String]
    let poster: String
    let producers: [String]
    let rating: String
    let releaseDate: String
    let runningTime: String
    let screenwriters: [String]
    let summary: String
    let title: String
    let trailer: String
    let wiki: String
    
    enum CodingKeys: String, CodingKey {
        case boxOffice = "box_office"
        case budget
        case cinematographers
        case directors
        case distributors
        case editors
        case musicComposers = "music_composers"
        case poster
        case producers
        case rating
        case releaseDate = "release_date"
        case runningTime = "running_time"
        case screenwriters
        case summary
        case title
        case trailer
        case wiki
    }
}

// MARK: - Sample Movie
extension MoviesResponse {
    static let sampleResponse = MoviesResponse(
        data: MovieModel.sampleData,
        meta: MetaModel.sampleMeta
    )
}

extension MovieModel {
    static let sampleData = [
        MovieModel(id: "406c41c1-babd-4ead-9567-9783c1742d39", attributes: MovieAttributes.sampleAttribute),
        MovieModel(id: "406c41c1-babd-4ead-9567-9783c1742d39", attributes: MovieAttributes.sampleAttribute),
    ]
}

extension MovieAttributes {
    static let sampleAttribute = MovieAttributes(
        boxOffice: "$1.018 million",
        budget: "$125 million",
        cinematographers: [
            "John Seale"
        ],
        directors: [
            "Chris Columbus"
        ],
        distributors: [
            "Warner Bros. Pictures"
        ],
        editors: [
            "Richard Francis-Bruce"
        ],
        musicComposers: [
            "John Williams",
            "Conrad Pope"
        ],
        poster: "https://www.wizardingworld.com/images/products/films/rectangle-1.png",
        producers: [
            "Chris Columbus",
            "David Heyman",
            "Mark Radcliffe"
        ],
        rating: "PG",
        releaseDate: "2001-11-04",
        runningTime: "152 minutes",
        screenwriters: [
            "Steve Kloves"
        ],
        summary: "Harry Potter’s dull life is completely changed on his eleventh birthday when a mysterious letter addressed to him arrives in the mail. After finding out about his real parents and a whole hidden wizarding world, he goes on to Hogwarts, his new magical school. From battling a troll to flying on broomsticks to catch golden snitches, Harry’s new life promises to be full of joy and adventure, until he finds out about a certain Dark Lord who murdered his parents is trying to regain power. With his friends Hermione and Ron, Harry sets out to find the philosopher’s stone before Voldemort to prevent his return. After advancing through a particularly difficult set of traps designed by the school, Harry faces the Dark Lord and manages to keep the Philosopher’s Stone safe.",
        title: "Harry Potter and the Philosopher's Stone",
        trailer: "https://www.youtube.com/watch?v=PbdM1db3JbY",
        wiki: "https://harrypotter.fandom.com/wiki/Harry_Potter_and_the_Philosopher's_Stone_(film)"
    )
}
