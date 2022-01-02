//
//  LyricsView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 27/10/21.
//

import SwiftUI

struct LyricsView: View {
    
    // User Defaults
    @AppStorage("visualizerStyle") private var visualizerStyle: VisualizerStyle = .albumArt
    
    // Properties
    let lyrics: String
    @Binding var showingLyrics: Bool
    @Binding var playbackScale: Double
    @Binding var lyricsScale: Double
    
    // Constants
    let primaryOpacity = 0.8
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        showingLyrics = false
                        playbackScale = 1.0
                        lyricsScale = 1.2
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(
                                visualizerStyle != .none
                                ? .white.opacity(primaryOpacity)
                                : .primary.opacity(primaryOpacity))
                    }
                    .pressButtonStyle()
                    Spacer()
                }
                Spacer()
            }
            VStack(alignment: .center) {
                Text(lyrics)
                    .multilineTextAlignment(.center)
                    .foregroundColor(
                        visualizerStyle != .none
                        ? .white.opacity(primaryOpacity)
                        : .primary.opacity(primaryOpacity))
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(22)
        }
        .padding()
    }
}
