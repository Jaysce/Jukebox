//
//  SpotifyClientCredentials.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 27/10/21.
//

import Foundation

struct SpotifyClientCredentials: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
