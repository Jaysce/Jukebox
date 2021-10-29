//
//  PreferencesView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 29/10/21.
//

import SwiftUI

struct PreferencesView: View {
    var body: some View {
        HStack(spacing: 0) {
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .frame(maxWidth: 120, maxHeight: .infinity)
            
            Divider()
            
            VStack {
                Text("Preferences")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
