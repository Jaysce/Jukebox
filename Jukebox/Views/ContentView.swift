//
//  ContentView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var contentViewVM = ContentViewModel()
    
    @State var value = 5.0
    
    var body: some View {
        
        ZStack {
            // TODO: Visualizer View
            Color.gray
            
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
                            Image(systemName: "link")
                                .chipStyle()
                            
                            // TODO: Lyrics, this button should only appear when lyrics available
                            Button {
                                // Show lyrics for the current track
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
                
                // TODO: Seeker
                Slider(value: $value)
                
                // Media Buttons
                HStack(spacing: 24) {
                    Button {
                        // Previous track
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white).opacity(0.8)
                    }
                    .pressButtonStyle()

                    Button {
                        // Play / Pause track
                    } label: {
                        Image(systemName: contentViewVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white).opacity(0.8)
                            .frame(width: 32, height: 32)
                    }
                    .pressButtonStyle()
                    
                    Button {
                        // Next track
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white).opacity(0.8)
                    }
                    .pressButtonStyle()
                }
            }
            .padding()
        }
        .onAppear(perform: contentViewVM.getTrackInformation)
    }
    
}
