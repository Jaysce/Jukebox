//
//  ContentViewModel.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import Foundation
import SwiftUI
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
    @Published var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Published var trackDuration: Double = 0
    @Published var seekerPosition: Double = 0
    
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
        self.track.album = spotifyApp.currentTrack?.album ?? "Unknown Album"
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
        
        // Post notification to update the menu bar track title
        updateMenuBarText()
        
    }
    
    private func updateMenuBarText() {
        DispatchQueue.main.async { [weak self] in
            guard let title = self?.track.title, let artist = self?.track.artist, let isPlaying = self?.isPlaying else { return }
            let trackInfo: [String: Any] = ["title": title, "artist": artist, "isPlaying": isPlaying]
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
    
}
