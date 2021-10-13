//
//  PressButtonStyle.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import Foundation
import SwiftUI

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? CGFloat(0.90) : 1.0)
            .animation(Animation.spring(response: 0.2, dampingFraction: 0.35, blendDuration: 1))
    }
}

extension Button {
    func pressButtonStyle() -> some View {
        self.buttonStyle(PressButtonStyle())
    }
}
