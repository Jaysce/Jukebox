//
//  ContentViewModel.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    
    // Track
    @Published var track = Track()
    @Published var isPlaying = false
    
    // Seeker
    @Published var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Published var trackDuration: Double = 0
    @Published var seekerPosition: Double = 0
    private var elapsedTime = 0.0
    private var timestamp: Date?
    
    init() {
        setupObservers()
        getPlayState()
        getTrackInformation()
        getCurrentSeekerPosition()
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
        
    }
    
    // MARK: - MR Notification Handlers
    
    @objc private func trackDidChange() {
        print("The currently playing track changed")
        getTrackInformation()
        // TODO: Fetch lyrics on track change
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
    
}
