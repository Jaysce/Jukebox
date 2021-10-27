//
//  NetworkManager.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 26/10/21.
//

import Foundation
import PromiseKit

class NetworkManager {
    
    static var shared: NetworkManager = {
        return NetworkManager()
    }()
    
    private init() {}
    
    // MARK: - API Calls
    
    /// Get the Access Token from the Spotify API to enable use of the API's features
    ///
    /// - Returns: A Promise containing either the Spotify Access Token Model or an error if failed
    func getSpotifyAccessToken() -> Promise<SpotifyClientCredentials> {
        return Promise { resolver in
            
            // Build URL
            guard let url = buildURL(host: "accounts.spotify.com", path: "/api/token") else {
                resolver.reject(NetworkError.invalidURL(description: "Failed to build URL to get Spotify Access Token."))
                return
            }
            
            // Initialise request content
            let encodedClientIDAndClientSecret = (Secrets.SPOTIFY_CLIENT_ID + ":" + Secrets.SPOTIFY_CLIENT_SECRET).toBase64()
            let headers = [
                "Authorization": "Basic \(encodedClientIDAndClientSecret)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            let body = "grant_type=client_credentials".data(using: .utf8)
            
            // Create request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = body
            
            // Send HTTP request
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error!)
                    resolver.reject(NetworkError.networkError(description: error?.localizedDescription))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(SpotifyClientCredentials.self, from: data)
                    resolver.fulfill(decoded)
                } catch let error {
                    resolver.reject(NetworkError.decodingFailed(description: "Failed to decode AccessToken into JSON.\n\(error.localizedDescription)"))
                }
                
            }.resume()
            
        }
    }
    
    /// Get the International Standard Recording Code (ISRC) for a given track from the Spotify API
    ///
    /// - Parameter song: A song object that contains details about the track e.g. Title and Artist
    /// - Parameter accessToken: The access token provided by Spotify to access the API
    /// - Returns: A Promise containing either the ISRC as a string or an error if failed
    func getISRC(for track: Track, using accessToken: String) -> Promise<String> {
        return Promise { resolver in
            
            // Build URL
            let params = [
                "q": "\(track.title) \(track.artist)",
                "type": "track",
                "limit": "1"
            ]
            
            guard let url = buildURL(host: "api.spotify.com", path: "/v1/search", queryItems: params) else {
                resolver.reject(NetworkError.invalidURL(description: "Failed to build URL to get ISRC for song."))
                return
            }
            
            // Initialise request content
            let headers = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
            
            // Create request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            // Send HTTP request
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    resolver.reject(NetworkError.networkError(description: error?.localizedDescription))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(SpotifySearchResult.self, from: data)
                    guard let isrc = decoded.getISRC() else {
                        resolver.reject(NetworkError.decodingFailed(description: "Failed to get ISRC from decoded SpotifySearchResult JSON."))
                        return
                    }
                    resolver.fulfill(isrc)
                } catch let error {
                    resolver.reject(NetworkError.decodingFailed(description: "Failed to decode SpotifySearchResult into JSON.\n\(error.localizedDescription)"))
                    print(error)
                }
            }.resume()
            
        }
    }
    
    /// Get the lyrics from the Musixmatch API given the International Standard Recording Code (ISRC) of the track
    ///
    /// - Parameter isrc: The International Standard Recording Code (ISRC) is a code that provides a means of identifying audio and video recordings
    /// - Returns: A Promise containing either the result model of Musixmatch lyrics or an error if failed
    func getLyricsForTrack(with isrc: String) -> Promise<MusixMatchLyrics> {
        return Promise { resolver in
            
            // Build URL
            let params = [
                "apikey": Secrets.MUSIXMATCH_API_KEY,
                "track_isrc": isrc
            ]
            
            guard let url = buildURL(host: "api.musixmatch.com", path: "/ws/1.1/track.lyrics.get", queryItems: params) else {
                resolver.reject(NetworkError.invalidURL(description: "Failed to build URL to get lyrics for track."))
                return
            }
            
            // Create request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Send HTTP request
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    resolver.reject(NetworkError.networkError(description: error?.localizedDescription))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(MusixMatchLyrics.self, from: data)
                    resolver.fulfill(decoded)
                } catch let error {
                    resolver.reject(NetworkError.decodingFailed(description: "Failed to decode MusixMatchSnippetResult into JSON.\n\(error.localizedDescription)"))
                }
            }.resume()
            
        }
    }
    
    // MARK: - Utility Functions
    
    /// Builds a URL given a host, path and query items
    ///
    /// - Parameter host: The host of the URL
    /// - Parameter path: Path or endpoint, e.g. for an API
    /// - Parameter queryItems: Query items for the URL
    /// - Returns: A constructed `https` schemed URL with the given components
    private func buildURL(host: String, path: String, queryItems: [String: String]? = nil) -> URL? {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = host
        components.path = path
        if let queryItems = queryItems {
            components.queryItems = queryItems.map({ key, value in
                URLQueryItem(name: key, value: value)
            })
        }
        
        return components.url
    }
    
}
