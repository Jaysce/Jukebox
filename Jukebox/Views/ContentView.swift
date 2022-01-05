//
//  ContentView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import SwiftUI

struct ContentView: View {
    
    // User Defaults
    @AppStorage("visualizerStyle") private var visualizerStyle: VisualizerStyle = .albumArt
    
    // View Model
    @ObservedObject var contentViewVM: ContentViewModel
    
    // States for animations
    @State private var isShowingPlaybackControls = false
    
    /* Currently not being used, Lyrics has been shelved for now
    @State private var showingLyrics = false
    @State private var playbackScale = 1.0
    @State private var lyricsScale = 1.2
     */
    
    // Constants
    let primaryOpacity = 0.8
    let primaryOpacity2 = 0.6
    let secondaryOpacity = 0.4
    let ternaryOpacity = 0.2
    
    var body: some View {
        
        ZStack {
            if visualizerStyle == .albumArt && contentViewVM.spotifyApp.isRunning {
                Image(nsImage: contentViewVM.track.albumArt)
                    .resizable()
                    .scaledToFill()
                    .padding(-12)
                VisualEffectView(material: .popover, blendingMode: .withinWindow)
                    .padding(-12)
            }
            
            if !contentViewVM.spotifyApp.isRunning {
                Text("Play something on \(Constants.Spotify.name)")
                    .foregroundColor(.primary.opacity(secondaryOpacity))
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            
                            // Playback Buttons
                            HStack(spacing: 6) {
                                Button {
                                    contentViewVM.previousTrack()
                                } label: {
                                    Image(systemName: "backward.end.fill")
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
                                    Image(systemName: "forward.end.fill")
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
                                .foregroundColor(.primary.opacity(primaryOpacity))
                                .font(.system(size: 15, weight: .bold))
                                .lineLimit(1)
                            Text(contentViewVM.track.artist)
                                .font(.headline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .foregroundColor(.primary.opacity(primaryOpacity2))
                            Text("\(formatSecondsForDisplay(contentViewVM.seekerPosition)) / \(formatSecondsForDisplay(contentViewVM.trackDuration))")
                                .foregroundColor(.primary.opacity(primaryOpacity2))
                                .font(.subheadline)
                                .padding(.top, 2)
                        }
                        .frame(width: 216, height: 68, alignment: .center)
                        .offset(y: 1)
                        .padding(.horizontal, 8)
                        
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
        let date = Date(timeIntervalSince1970: seconds)
        let hours = Int(seconds / 3600)
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        if (hours > 0) { formatter.dateFormat = "H:m:ss" }
        else { formatter.dateFormat = "m:ss" }

        return formatter.string(from: date)
    }
    
}
