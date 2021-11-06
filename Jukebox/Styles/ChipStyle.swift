//
//  Chip.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import Foundation
import SwiftUI

struct ChipStyle: ViewModifier {
    
    @AppStorage("visualizerStyle") private var visualizerStyle: VisualizerStyle = .gradient
    
    // Constants
    let primaryOpacity = 0.8
    let ternaryOpacity = 0.2
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(
                visualizerStyle != .none
                ? .white.opacity(primaryOpacity)
                : .primary.opacity(primaryOpacity))
            .padding(.vertical, 3)
            .padding(.horizontal, 10)
            .background(
                visualizerStyle != .none
                ? Color.white.opacity(ternaryOpacity)
                : Color.primary.opacity(ternaryOpacity))
            .cornerRadius(20)
    }
}

extension View {
    func chipStyle() -> some View {
        self.modifier(ChipStyle())
    }
}
