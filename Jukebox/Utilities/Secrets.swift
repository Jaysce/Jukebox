//
//  Secrets.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 27/10/21.
//

import Foundation

struct Secrets {
    
    private init() {}
    
    static var SPOTIFY_CLIENT_ID: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
                fatalError("Couldn't find file 'Secrets.plist'.")
            }
            
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "SPOTIFY_CLIENT_ID") as? String else {
                fatalError("Couldn't find key 'SPOTIFY_CLIENT_ID' in 'Secrets.plist'.")
            }
            return value
        }
    }
    
    static var SPOTIFY_CLIENT_SECRET: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
                fatalError("Couldn't find file 'Secrets.plist'.")
            }
            
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "SPOTIFY_CLIENT_SECRET") as? String else {
                fatalError("Couldn't find key 'SPOTIFY_CLIENT_SECRET' in 'Secrets.plist'.")
            }
            return value
        }
    }
    
    static var MUSIXMATCH_API_KEY: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
                fatalError("Couldn't find file 'Secrets.plist'.")
            }
            
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "MUSIXMATCH_API_KEY") as? String else {
                fatalError("Couldn't find key 'MUSIXMATCH_API_KEY' in 'Secrets.plist'.")
            }
            return value
        }
    }
    
}
