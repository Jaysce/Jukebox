//
//  SpotifySearchResult.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 27/10/21.
//

import Foundation

struct SpotifySearchResult: Codable {
    let tracks: Tracks
    
    func getISRC() -> String? {
        tracks.items.first?.externalIDS.isrc
    }
}

struct Tracks: Codable {
    let items: [Item]
}

struct Item: Codable {
    let artists: [Artist]
    let externalIDS: ExternalIDS

    enum CodingKeys: String, CodingKey {
        case artists
        case externalIDS = "external_ids"
    }
}

struct Artist: Codable {
    let href: String
    let id, name, type, uri: String

    enum CodingKeys: String, CodingKey {
        case href, id, name, type, uri
    }
}

struct ExternalIDS: Codable {
    let isrc: String
}
