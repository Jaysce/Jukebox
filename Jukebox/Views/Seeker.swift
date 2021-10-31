//
//  Seeker.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 26/10/21.
//

import SwiftUI

struct Seeker: View {
    
    var trackDuration: Double
    @Binding var seekerPosition: Double
    let onEditingChanged: (Bool) -> Void
    
    @State private var seekerHeight: CGFloat = 4
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.white.opacity(0.2))
                    Rectangle()
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: geo.size.width * CGFloat(self.seekerPosition / trackDuration))
                        .animation(.easeInOut, value: self.seekerPosition)
                    SwipeView(seekerPosition: self.$seekerPosition, onEditingChanged: onEditingChanged)
                }
                .frame(width: geo.size.width, height: seekerHeight)
                .cornerRadius(6)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            onEditingChanged(true)
                            self.seekerPosition = min(max(0, Double(value.location.x / geo.size.width * trackDuration)), trackDuration)
                        })
                        .onEnded({ _ in
                            onEditingChanged(false)
                        }))
                HStack {
                    Text(formatSecondsForDisplay(seekerPosition))
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                    Spacer()
                    Text(formatSecondsForDisplay(trackDuration))
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onHover { hovered in
                if (hovered) {
                    withAnimation(.timingCurve(0.12, 0.76, 0.44, 0.99)) {
                        self.seekerHeight = 16
                    }
                } else {
                    withAnimation(.timingCurve(0.12, 0.76, 0.44, 0.99)) {
                        self.seekerHeight = 4
                    }
                }
            }
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
