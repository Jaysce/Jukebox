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
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    var spotifyApp: SpotifyApplication?
    var appleMusicApp: MusicApplication?
    
    var name: String {
        connectedApp == .spotify ? Constants.Spotify.name : Constants.AppleMusic.name
    }
    
    var isRunning: Bool {
        connectedApp == .spotify ? spotifyApp?.isRunning ?? false : appleMusicApp?.isRunning ?? false
    }
    
    var notification: String {
        connectedApp == .spotify ? Constants.Spotify.notification : Constants.AppleMusic.notification
    }
    
    // Popover
    @Published var popoverIsShown = true
    
    // Track
    @Published var track = Track()
    @Published var isPlaying = false
    
    // Seeker
    @Published var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Published var trackDuration: Double = 0
    @Published var seekerPosition: Double = 0
    
    private var observer: NSKeyValueObservation?
    
    init() {
        setupMusicApps()
        setupObservers()
        guard isRunning else { return }
        playStateOrTrackDidChange(nil)
    }
    
    deinit {
        observer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupMusicApps() {
        print("Setting up music apps")
        switch connectedApp {
        case .spotify:
            guard spotifyApp == nil else { return }
            spotifyApp = SBApplication(bundleIdentifier: Constants.Spotify.bundleID)
        case .appleMusic:
            guard appleMusicApp == nil else { return }
            appleMusicApp = SBApplication(bundleIdentifier: Constants.AppleMusic.bundleID)
        }
    }
    
    private func setupObservers() {
        
        observer = UserDefaults.standard.observe(\.connectedApp, options: [.old, .new]) { defaults, change in
            DistributedNotificationCenter.default().removeObserver(self)
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(self.playStateOrTrackDidChange),
                name: NSNotification.Name(rawValue: self.notification),
                object: nil,
                suspensionBehavior: .deliverImmediately)
            self.setupMusicApps()
            self.playStateOrTrackDidChange(nil)
        }
                
        // ScriptingBridge Observer
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(playStateOrTrackDidChange),
            name: NSNotification.Name(rawValue: notification),
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
        setupMusicApps()
        guard isRunning, sender?.userInfo?["Player State"] as? String != "Stopped" else {
            self.track.title = ""
            self.track.artist = ""
            self.track.albumArt = NSImage()
            self.trackDuration = 0
            updateMenuBarText()
            return
        }
        
        print("The play state or the currently playing track changed")
        getPlayState()
        getTrackInformation()
    }
    
    // MARK: - Media & Playback
    
    private func getPlayState() {
        isPlaying = connectedApp == .spotify
        ? spotifyApp?.playerState == .playing
        : appleMusicApp?.playerState == .playing
    }
    
    func getTrackInformation() {
        
        print("Getting track information...")
        
        switch connectedApp {
        case .spotify:
            
            // Track
            self.track.title = spotifyApp?.currentTrack?.name ?? "Unknown Title"
            self.track.artist = spotifyApp?.currentTrack?.artist ?? "Unknown Artist"
            self.track.album = spotifyApp?.currentTrack?.album ?? "Unknown Album"
            if let artworkURLString = spotifyApp?.currentTrack?.artworkUrl,
               let url = URL(string: artworkURLString) {
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    guard let data = data, error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    DispatchQueue.main.async {
                        self?.track.albumArt = NSImage(data: data) ?? NSImage()
                    }
                    
                }.resume()
            }
            
            // Seeker
            self.trackDuration = Double(spotifyApp?.currentTrack?.duration ?? 0) / 1000
            
        case .appleMusic:
            
            // Track
            self.track.title = appleMusicApp?.currentTrack?.name ?? "Unknown Title"
            self.track.artist = appleMusicApp?.currentTrack?.artist ?? "Unknown Artist"
            self.track.album = appleMusicApp?.currentTrack?.album ?? "Unknown Album"
            
            // Might have to change this later...
            var count = 0
            var waitForData: (() -> Void)!
            waitForData = {
                let art = self.appleMusicApp?.currentTrack?.artworks?()[0] as! MusicArtwork
                if art.data != nil && !art.data!.isEmpty() {
                    self.track.albumArt = art.data!
                } else {
                    if count > 20 { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        waitForData()
                    }
                }
                count += 1
            }
            waitForData()
            
            // Seeker
            self.trackDuration = Double(appleMusicApp?.currentTrack?.duration ?? 0)
            
        }
        
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
        switch connectedApp {
        case .spotify:
            spotifyApp?.playpause?()
        case .appleMusic:
            appleMusicApp?.playpause?()
        }
    }
    
    func previousTrack() {
        switch connectedApp {
        case .spotify:
            spotifyApp?.previousTrack?()
        case .appleMusic:
            appleMusicApp?.backTrack?()
        }
    }
    
    func nextTrack() {
        switch connectedApp {
        case .spotify:
            spotifyApp?.nextTrack?()
        case .appleMusic:
            appleMusicApp?.nextTrack?()
        }
    }
    
    // MARK: - Seeker
    
    func getCurrentSeekerPosition() {
        guard isRunning else { return }
        self.seekerPosition = connectedApp == .spotify
        ? Double(spotifyApp?.playerPosition ?? 0)
        : Double(appleMusicApp?.playerPosition ?? 0)
    }
    
    func seekTrack() {
        spotifyApp?.setPlayerPosition?(seekerPosition)
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
