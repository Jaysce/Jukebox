//
//  ContentViewModel.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import Foundation

class ContentViewModel: ObservableObject {
    
    @Published var track = Track()
    
    init() {
        setupObservers()
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
    }
    
    @objc private func playStateDidChange() {
        print("The play state changed")
    }
    
    @objc private func applicationDidChange() {
        print("The application changed")
    }
    
}
