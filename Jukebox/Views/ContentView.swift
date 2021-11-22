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
    @State private var isShowingPlaybackControls = false
    // Currently not being used, Lyrics has been shelved for now
    /*
    @State private var showingLyrics = false
    @State private var playbackScale = 1.0
    @State private var lyricsScale = 1.2
     */
    
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
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 0) {
                    // Media details
                    VStack {
                        // Album art image
                        ZStack {
                            Rectangle()
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(ternaryOpacity)
                                    : .primary.opacity(ternaryOpacity))
                                .frame(width: 240, height: 240)
                                .cornerRadius(8)
                            
                            Image(nsImage: contentViewVM.track.albumArt)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 240, height: 240)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            // Playback Buttons
                            HStack(spacing: 6) {
                                Button {
                                    contentViewVM.previousTrack()
                                } label: {
                                    Image(systemName: "backward.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary.opacity(primaryOpacity))
                                }
                                .pressButtonStyle()
                                
                                Button {
                                    contentViewVM.togglePlayPause()
                                } label: {
                                    Image(systemName: contentViewVM.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.primary.opacity(primaryOpacity))
                                        .frame(width: 25, height: 25)
                                }
                                .pressButtonStyle()
                                
                                Button {
                                    contentViewVM.nextTrack()
                                } label: {
                                    Image(systemName: "forward.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.primary.opacity(primaryOpacity))
                                }
                                .pressButtonStyle()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
                            .cornerRadius(100)
                            .opacity(isShowingPlaybackControls ? 1 : 0)
                            
                        }
                        .onHover { _ in
                            withAnimation(.linear(duration: 0.1)) {
                                self.isShowingPlaybackControls.toggle()
                            }
                            
                        }
                        
                        Spacer()
                        
                        // Track details
                        VStack(alignment: .center) {
                            Text(contentViewVM.track.title)
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(primaryOpacity)
                                    : .primary.opacity(primaryOpacity))
                                .font(.system(size: 18, weight: .bold))
                                .lineLimit(1)
                            Text(contentViewVM.track.artist)
                                .font(.headline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(primaryOpacity)
                                    : .primary.opacity(primaryOpacity))
                            Text("\(formatSecondsForDisplay(contentViewVM.seekerPosition)) / \(formatSecondsForDisplay(contentViewVM.trackDuration))")
                                .foregroundColor(
                                    visualizerStyle != .none
                                    ? .white.opacity(0.6)
                                    : .primary.opacity(0.6))
                                .font(.subheadline)
                                .padding(.top, 2)
                        }
                        .frame(width: .infinity, height: 68)
                        
                    }
                    
                }
                .padding()
            }
        }
        .onAppear(perform: {
            contentViewVM.playStateOrTrackDidChange(nil)
        })
        .onReceive(contentViewVM.timer) { _ in
            contentViewVM.getCurrentSeekerPosition()
        }
    }
    
    private func formatSecondsForDisplay(_ seconds: Double) -> String {
        let date = Date.init(timeIntervalSince1970: seconds)
        let hours = Int(seconds / 3600)
        
        let formatter = DateFormatter()
        if (hours > 0) { formatter.dateFormat = "H:m:ss" }
        else { formatter.dateFormat = "m:ss" }

        return formatter.string(from: date)
    }
    
}
