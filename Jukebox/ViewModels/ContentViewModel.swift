//
//  ContentViewModel.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import Foundation
import SwiftUI
import PromiseKit
import ScriptingBridge

class ContentViewModel: ObservableObject {
    
    // Music Applications
    let spotifyApp: SpotifyApplication = SBApplication(bundleIdentifier: Constants.Spotify.bundleID)!
    // TODO: Apple Music
    
    // Popover
    @Published var popoverIsShown = true
    
    // Track
    @Published var track = Track()
    @Published var isPlaying = false
    
    // Seeker
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var trackDuration: Double = 0
    @Published var seekerPosition: Double = 0
    
    // Lyrics
    private var accessToken: String?
    private var accessTokenExpiryDate: Date?
    
    init() {
        setupObservers()
        guard spotifyApp.isRunning else { return }
        playStateOrTrackDidChange(nil)
    }
    
    // MARK: - Observers
    
    private func setupObservers() {
        
        // ScriptingBridge Observer
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(playStateOrTrackDidChange),
            name: NSNotification.Name(rawValue: Constants.Spotify.notification),
            object: nil,
            suspensionBehavior: .deliverImmediately)
        
        // Add observer to listen for popover open
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(popoverIsOpening),
            name: NSPopover.willShowNotification,
            object: nil)
        
        // Add observer to listen for popover close
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(popoverIsClosing),
            name: NSPopover.didCloseNotification,
            object: nil)
        
    }
    
    // MARK: - Notification Handlers
    
    @objc func playStateOrTrackDidChange(_ sender: NSNotification?) {
        guard spotifyApp.isRunning else { return }
        guard sender?.userInfo?["Player State"] as? String != "Stopped" else {
            self.track.title = ""
            self.track.artist = ""
            updateMenuBarText()
            return
        }
        
        print("The play state or the currently playing track changed")
        getPlayState()
        getTrackInformation()
        getCurrentSeekerPosition()
        fetchLyrics()
    }
    
    // MARK: - Media & Playback
    
    private func getPlayState() {
        switch spotifyApp.playerState {
        case.playing: self.isPlaying = true
        default: self.isPlaying = false
        }
    }
    
    func getTrackInformation() {
        
        print("Getting track information...")
        
        // Track
        self.track.title = spotifyApp.currentTrack?.name ?? "Unknown Title"
        self.track.artist = spotifyApp.currentTrack?.artist ?? "Unknown Artist"
        if let artworkURLString = spotifyApp.currentTrack?.artworkUrl,
           let url = URL(string: artworkURLString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                self?.track.albumArt = NSImage(data: data) ?? NSImage()
                
            }.resume()
        }
        
        // Seeker
        self.trackDuration = Double(spotifyApp.currentTrack?.duration ?? 0) / 1000
        self.seekerPosition = Double(spotifyApp.playerPosition ?? 0)
        
        // Post notification to update the menu bar track title
        updateMenuBarText()
        
    }
    
    private func updateMenuBarText() {
        DispatchQueue.main.async { [weak self] in
            guard let title = self?.track.title, let artist = self?.track.artist else { return }
            let trackInfo: [String: String] = ["title": title, "artist": artist]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TrackChanged"), object: nil, userInfo: trackInfo)
        }
    }
    
    func togglePlayPause() {
        spotifyApp.playpause?()
    }
    
    func previousTrack() {
        spotifyApp.previousTrack?()
    }
    
    func nextTrack() {
        spotifyApp.nextTrack?()
    }
    
    // MARK: - Seeker
    
    func getCurrentSeekerPosition() {
        guard spotifyApp.isRunning else { return }
        self.seekerPosition = Double(spotifyApp.playerPosition ?? 0)
    }
    
    func seekTrack() {
        spotifyApp.setPlayerPosition?(seekerPosition)
    }
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    func pauseTimer() {
        timer.upstream.connect().cancel()
    }
    
    @objc private func popoverIsOpening(_ notification: NSNotification) {
        startTimer()
        popoverIsShown = true
    }
    
    @objc private func popoverIsClosing(_ notification: NSNotification) {
        pauseTimer()
        popoverIsShown = false
    }
    
    // MARK: - Lyrics
    
    private func fetchAccessToken() {
        
        print("Fetching Access Token...")
        
        let networkManager = NetworkManager.shared
        
        firstly {
            networkManager.getSpotifyAccessToken()
        }.done { tokenInfo in
            self.accessToken = tokenInfo.accessToken
            self.accessTokenExpiryDate = Date().addingTimeInterval(TimeInterval(tokenInfo.expiresIn))
            self.fetchLyrics()
        }.catch { error in
            print(error.localizedDescription)
            self.track.lyrics = "Something went wrong..."
        }
        
    }
    
    private func fetchLyrics() {
        
        let networkManager = NetworkManager.shared
        
        // If access token or access token expiry is nil, fetch access token
        guard let accessToken = accessToken, let expiryDate = accessTokenExpiryDate else {
            fetchAccessToken()
            return
        }
        
        // If access token is expired, fetch access token
        guard Date() < expiryDate else {
            fetchAccessToken()
            return
        }
        
        print("Fetching Lyrics...")
        
        // Fetch the lyrics for the currently playing song
        firstly {
            networkManager.getISRC(for: track, using: accessToken)
        }.then { isrc in
            networkManager.getLyricsForTrack(with: isrc)
        }.done { musixMatchLyrics in
            self.track.lyrics = musixMatchLyrics.getLyrics() ?? "No lyrics for current song..."
        }.catch { error in
            print(error.localizedDescription)
            self.track.lyrics = "No lyrics for current song..."
        }
        
    }
    
}
