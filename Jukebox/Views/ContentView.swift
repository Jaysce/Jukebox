//
//  ContentView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import SwiftUI

struct ContentView: View {
    
    // View Model
    @ObservedObject var contentViewVM: ContentViewModel
    
    // States for animations
    @State private var showingLyrics = false
    @State private var playbackScale = 1.0
    @State private var lyricsScale = 1.2
    
    var body: some View {
        
        ZStack {
            // TODO: Visualizer View
            MetalView(popoverIsShown: contentViewVM.popoverIsShown).padding(-80)
            
            VStack(spacing: 16) {
                // Media details
                HStack {
                    // Album art image
                    ZStack {
                        Rectangle()
                            .foregroundColor(.white.opacity(0.2))
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
                            .foregroundColor(.white).opacity(0.8)
                            .font(.system(size: 20, weight: .bold))
                            .lineLimit(1)
                        Text(contentViewVM.track.artist)
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundColor(.white).opacity(0.4)
                        
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
                    }
                    .padding(.vertical, 6)
                    
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
                            .foregroundColor(.white).opacity(0.8)
                    }
                    .pressButtonStyle()

                    Button {
                        contentViewVM.togglePlayPause()
                    } label: {
                        Image(systemName: contentViewVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white).opacity(0.8)
                            .frame(width: 32, height: 32)
                    }
                    .pressButtonStyle()
                    
                    Button {
                        contentViewVM.nextTrack()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white).opacity(0.8)
                    }
                    .pressButtonStyle()
                }
            }
            .padding()
            .opacity(showingLyrics ? 0 : 1)
            .scaleEffect(playbackScale)
            .animation(.timingCurve(0.12,0.76,0.44,0.99), value: playbackScale)
            .animation(.timingCurve(0.12,0.76,0.44,0.99), value: showingLyrics)
            
            LyricsView(lyrics: contentViewVM.track.lyrics, showingLyrics: $showingLyrics, playbackScale: $playbackScale, lyricsScale: $lyricsScale)
                .opacity(showingLyrics ? 1 : 0)
                .scaleEffect(lyricsScale)
                .animation(.timingCurve(0.12,0.76,0.44,0.99), value: lyricsScale)
                .animation(.timingCurve(0.12,0.76,0.44,0.99), value: showingLyrics)
        }
        .onAppear(perform: contentViewVM.getTrackInformation)
        .onReceive(contentViewVM.timer) { _ in
            contentViewVM.getCurrentSeekerPosition()
        }
    }
    
}
