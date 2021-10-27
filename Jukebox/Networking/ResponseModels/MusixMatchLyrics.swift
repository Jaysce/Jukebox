//
//  MusixMatchLyrics.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 27/10/21.
//

import Foundation

struct MusixMatchLyrics: Codable {
    let message: Message
    
    func getLyrics() -> String? {
        return message.body.lyrics.lyricsBody
    }
}

struct Message: Codable {
    let body: Body
}

struct Body: Codable {
    let lyrics: Lyrics
}

struct Lyrics: Codable {
    let lyricsBody: String
    let scriptTrackingURL: String
    let pixelTrackingURL: String
    let lyricsCopyright: String

    enum CodingKeys: String, CodingKey {
        case lyricsBody = "lyrics_body"
        case scriptTrackingURL = "script_tracking_url"
        case pixelTrackingURL = "pixel_tracking_url"
        case lyricsCopyright = "lyrics_copyright"
    }
}
