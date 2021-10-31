//
//  PreferencesView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 29/10/21.
//

import SwiftUI

struct PreferencesView: View {
    
    weak var parentWindow: PreferencesWindow!
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                CloseButton(parentWindow: parentWindow)
                AppInfo().offset(x: 1) // Looks like it was off center (?)
            }
            .frame(maxWidth: 140, maxHeight: .infinity)
            
            Divider()
            
            PreferencePanes()
        }
        .ignoresSafeArea()
    }
}

struct CloseButton: View {
    
    weak var parentWindow: PreferencesWindow!
    @State private var isHoveringCloseButton = false
    
    var body: some View {
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
}

struct AppInfo: View {
    
    let jukeboxRepo = "https://github.com/Jaysce/Jukebox"
    let jukeboxWebPage = "https://jaysce.dev"
    
    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            HStack {
                Button {
                    NSWorkspace.shared.open(URL(string: jukeboxRepo)!)
                } label: {
                    Text("GitHub").font(.system(size: 12))
                }
                .buttonStyle(LinkButtonStyle())
                
                Button {
                    NSWorkspace.shared.open(URL(string: jukeboxWebPage)!)
                } label: {
                    Text("Website").font(.system(size: 12))
                }
                .buttonStyle(LinkButtonStyle())
            }
        }
    }
}

struct PreferencePanes: View {
    
    private var visualizers = ["None", "Gradient", "Waves", "Abstract"]
    @State private var launchAtLogin = false
    @State private var selectedVisualization = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading) {
                        Text("General")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Toggle("Launch Jukebox on login", isOn: $launchAtLogin)
                    }
                    .padding()
                    .frame(width: geo.size.width, height: geo.size.height / 3, alignment: .topLeading)
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Menu Bar")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Toggle("Disable menu bar animation", isOn: $launchAtLogin)
                        Toggle("Disable menu bar marquee text", isOn: $launchAtLogin)
                        
                    }
                    .padding()
                    .frame(width: geo.size.width, height: geo.size.height / 3, alignment: .topLeading)
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Visualizer")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Picker("Style", selection: $selectedVisualization) {
                            ForEach(0..<visualizers.count) { index in
                                Text(visualizers[index]).tag(index)
                            }
                        }
                        
                    }
                    .padding()
                    .frame(width: geo.size.width, height: geo.size.height / 3, alignment: .topLeading)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
