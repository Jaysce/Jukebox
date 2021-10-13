//
//  Chip.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import Foundation
import SwiftUI

struct ChipStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
            .padding(.vertical, 3)
            .padding(.horizontal, 10)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
    }
}

extension View {
    func chipStyle() -> some View {
        self.modifier(ChipStyle())
    }
}
