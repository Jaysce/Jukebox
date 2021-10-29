//
//  PreferencesView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 29/10/21.
//

import SwiftUI

struct PreferencesView: View {
    
    weak var parentWindow: PreferencesWindow!
    @State private var isHoveringCloseButton = false
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                VStack {
                    HStack {
                        Button {
                            parentWindow.close()
                            isHoveringCloseButton = false
                        } label: {
                            Image(isHoveringCloseButton ? "close_hover" : "close")
                        }
                        .pressButtonStyle()
                        .onHover(perform: { hovering in
                            if hovering { isHoveringCloseButton = true }
                            else { isHoveringCloseButton = false }
                        })
                        .padding(12)
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
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
