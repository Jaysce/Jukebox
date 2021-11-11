//
//  ContentView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import SwiftUI

struct ContentView: View {
    
    // User Defaults
    @AppStorage("visualizerStyle") private var visualizerStyle: VisualizerStyle = .gradient
    
    // View Model
    @ObservedObject var contentViewVM: ContentViewModel
    
    // States for animations
    @State private var showingLyrics = false
    @State private var playbackScale = 1.0
    @State private var lyricsScale = 1.2
    
    // Constants
    let primaryOpacity = 0.8
    let secondaryOpacity = 0.4
    let ternaryOpacity = 0.2
    
    var body: some View {
        
        ZStack {
            if visualizerStyle == .gradient {
                MetalView(popoverIsShown: contentViewVM.popoverIsShown).padding(-80)
            }
            
            if !contentViewVM.spotifyApp.isRunning {
                Text("Play something on \(Constants.Spotify.name)")
                    .foregroundColor(
                        visualizerStyle != .none
                        ? .white.opacity(secondaryOpacity)
                        : .primary.opacity(secondaryOpacity))
                    .font(.system(size: 24, weight: .bold))
            } else {
                VStack(spacing: 16) {
                    // Media details
                    HStack {
                        // Album art image
                        ZStack {
                            Rectangle()
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(ternaryOpacity)
                                    : .primary.opacity(ternaryOpacity))
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                            
                            Image(nsImage: contentViewVM.track.albumArt)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                        }
                        
                        // Track details
                        VStack(alignment: .leading) {
                            Text(contentViewVM.track.title)
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(primaryOpacity)
                                    : .primary.opacity(primaryOpacity))
                                .font(.system(size: 20, weight: .bold))
                                .lineLimit(1)
                            Text(contentViewVM.track.artist)
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(secondaryOpacity)
                                    : .primary.opacity(secondaryOpacity))
                            
                            Spacer()
                            
                            // Linked App and Lyrics
                            HStack(spacing: 4) {
                                // TODO: Make adaptive to current application
                                Button {
                                    // Ability to switch active music apps
                                } label: {
                                    Image(systemName: "link")
                                        .chipStyle()
                                }
                                .pressButtonStyle()
                                
                                // TODO: Lyrics, this button should only appear when lyrics available
                                Button {
                                    self.showingLyrics = true
                                    self.playbackScale = 0.8
                                    self.lyricsScale = 1
                                } label: {
                                    Image(systemName: "quote.bubble.fill")
                                        .chipStyle()
                                }
                                .pressButtonStyle()
                            }
                            .padding(.bottom, 4)
                        }
                        .frame(width: .infinity, height: 80)
                        
                        Spacer()
                    }
                    
                    Seeker(trackDuration: contentViewVM.trackDuration, seekerPosition: $contentViewVM.seekerPosition) { isDragging in
                        if (isDragging) {
                            contentViewVM.pauseTimer()
                        } else {
                            contentViewVM.seekTrack()
                            contentViewVM.startTimer()
                        }
                    }
                    
                    // Playback Buttons
                    HStack(spacing: 24) {
                        Button {
                            contentViewVM.previousTrack()
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 20))
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(primaryOpacity)
                                    : .primary.opacity(primaryOpacity))
                        }
                        .pressButtonStyle()

                        Button {
                            contentViewVM.togglePlayPause()
                        } label: {
                            Image(systemName: contentViewVM.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(primaryOpacity)
                                    : .primary.opacity(primaryOpacity))
                                .frame(width: 32, height: 32)
                        }
                        .pressButtonStyle()
                        
                        Button {
                            contentViewVM.nextTrack()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 20))
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(primaryOpacity)
                                    : .primary.opacity(primaryOpacity))
                        }
                        .pressButtonStyle()
                    }
                }
                .padding()
                .opacity(showingLyrics ? 0 : 1)
                .scaleEffect(playbackScale)
                .animation(.timingCurve(0.12,0.76,0.44,0.99), value: playbackScale)
                .animation(.timingCurve(0.12,0.76,0.44,0.99), value: showingLyrics)
            }
            
            LyricsView(lyrics: contentViewVM.track.lyrics, showingLyrics: $showingLyrics, playbackScale: $playbackScale, lyricsScale: $lyricsScale)
                .opacity(showingLyrics ? 1 : 0)
                .scaleEffect(lyricsScale)
                .animation(.timingCurve(0.12,0.76,0.44,0.99), value: lyricsScale)
                .animation(.timingCurve(0.12,0.76,0.44,0.99), value: showingLyrics)
        }
        .onAppear(perform: {
            contentViewVM.playStateOrTrackDidChange(nil)
        })
        .onReceive(contentViewVM.timer) { _ in
            contentViewVM.getCurrentSeekerPosition()
        }
    }
    
}
