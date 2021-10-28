//
//  ContentViewModel.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import Foundation
import SwiftUI
import PromiseKit

class ContentViewModel: ObservableObject {
    
    // Popover
    @Published var popoverIsShown = true
    
    // Track
    @Published var track = Track()
    @Published var isPlaying = false
    
    // Seeker
    @Published var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Published var trackDuration: Double = 0
    @Published var seekerPosition: Double = 0
    private var elapsedTime = 0.0
    private var timestamp: Date?
    
    // Lyrics
    private var accessToken: String?
    private var accessTokenExpiryDate: Date?
    
    init() {
        setupObservers()
        getPlayState()
        getTrackInformation()
        getCurrentSeekerPosition()
        fetchLyrics()
    }
    
    // MARK: - Observers
    
    private func setupObservers() {
        
        // Register NotificationCenter to listen for MediaRemote notifications
        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)
        
        // Add observer to listen for track change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidChange),
            name: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"),
            object: nil)
        
        // Add observer to listen for play state change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playStateDidChange),
            name: NSNotification.Name("kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification"),
            object: nil)
        
        // Add observer to listen for application change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidChange),
            name: NSNotification.Name("kMRMediaRemoteNowPlayingApplicationDidChangeNotification"),
            object: nil)
        
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
    
    // MARK: - MR Notification Handlers
    
    @objc private func trackDidChange() {
        print("The currently playing track changed")
        getTrackInformation()
        fetchLyrics()
    }
    
    @objc private func playStateDidChange() {
        print("The play state changed")
        getPlayState()
    }
    
    @objc private func applicationDidChange() {
        print("The application changed")
    }
    
    // MARK: - Media & Playback
    
    private func getPlayState() {
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(DispatchQueue.main) { [weak self] isPlaying in
            guard let self = self else { return }
            self.isPlaying = isPlaying
        }
    }
    
    func getTrackInformation() {
        
        print("Getting track information...")
        
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { [weak self] trackInformation in
            
            guard let self = self else { return }
            guard let trackInformation = trackInformation as? [String: AnyObject] else { return }
            
            // Track
            self.track.title = trackInformation["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? "Unknown Title"
            self.track.artist = trackInformation["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? "Unknown Artist"
            let albumArtData = trackInformation["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data
            self.track.albumArt = NSImage(data: albumArtData ?? Data()) ?? NSImage()
            
            // Seeker
            self.trackDuration = trackInformation["kMRMediaRemoteNowPlayingInfoDuration"] as? Double ?? 0
            self.elapsedTime = trackInformation["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double ?? 0
            self.timestamp = trackInformation["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date ?? Date()
            
            // Post notification to update the menu bar track title
            let trackInfo: [String: String] = ["title": self.track.title, "artist": self.track.artist]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TrackChanged"), object: nil, userInfo: trackInfo)
            
        }
        
    }
    
    func togglePlayPause() {
        MRMediaRemoteSendCommand(kMRTogglePlayPause, nil)
    }
    
    func previousTrack() {
        MRMediaRemoteSendCommand(kMRPreviousTrack, nil)
    }
    
    func nextTrack() {
        MRMediaRemoteSendCommand(kMRNextTrack, nil)
    }
    
    // MARK: - Seeker
    
    func getCurrentSeekerPosition() {
        guard let timestamp = timestamp else { return }
        if (isPlaying) {
            seekerPosition = elapsedTime + Date().timeIntervalSince(timestamp)
        } else {
            // This needs to change maybe
            elapsedTime = seekerPosition
            seekerPosition = elapsedTime
        }
    }
    
    func seekTrack() {
        MRMediaRemoteSetElapsedTime(seekerPosition)
    }
    
    func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
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
        }.done { [weak self] tokenInfo in
            self?.accessToken = tokenInfo.accessToken
            self?.accessTokenExpiryDate = Date().addingTimeInterval(TimeInterval(tokenInfo.expiresIn))
            self?.fetchLyrics()
        }.catch { [weak self] error in
            print(error.localizedDescription)
            self?.track.lyrics = "Something went wrong..."
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
        firstly { [weak self] in
            networkManager.getISRC(for: self!.track, using: accessToken)
        }.then { isrc in
            networkManager.getLyricsForTrack(with: isrc)
        }.done { [weak self] musixMatchLyrics in
            self?.track.lyrics = musixMatchLyrics.getLyrics() ?? "No lyrics for current song..."
        }.catch { [weak self] error in
            print(error.localizedDescription)
            self?.track.lyrics = "No lyrics for current song..."
        }
        
    }
    
}
