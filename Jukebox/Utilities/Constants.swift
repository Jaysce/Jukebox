//
//  Constants.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 6/11/21.
//

import Foundation
import AppKit

enum Constants {
    
    enum AppInfo {
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        static let repo = URL(string: "https://github.com/Jaysce/Jukebox")!
        static let website = URL(string: "https://jaysce.dev/projects/jukebox")!
    }
    
    enum StatusBar {
        static let marqueeFont = NSFont.systemFont(ofSize: 13, weight: .medium)
        static let barAnimationWidth: CGFloat = 14
        static let statusBarButtonLimit: CGFloat = 200
        static let statusBarButtonPadding: CGFloat = 8
    }
    
    enum Spotify {
        static let name = "Spotify"
        static let bundleID = "com.spotify.client"
        static let notification = "\(bundleID).PlaybackStateChanged"
    }
    
    enum AppleMusic {
        static let name = "Apple Music"
        static let bundleID = "com.apple.Music"
        static let notification = "\(bundleID).playerInfo"
    }
    
}
