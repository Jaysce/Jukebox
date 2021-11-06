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
        VStack(spacing: 0) {
            ZStack {
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                CloseButton(parentWindow: parentWindow)
                AppInfo()
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            
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
            Spacer()
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
                .padding(.leading, 12)
                Spacer()
            }
            Spacer()
        }
    }
}

struct AppInfo: View {
    
    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Jukebox").font(.headline)
                    Text("Version \(Constants.AppInfo.appVersion ?? "?")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading)
            
            Spacer()
            
            HStack {
                Button {
                    NSWorkspace.shared.open(Constants.AppInfo.repo)
                } label: {
                    Text("GitHub").font(.system(size: 12))
                }
                .buttonStyle(LinkButtonStyle())
                
                Button {
                    NSWorkspace.shared.open(Constants.AppInfo.website)
                } label: {
                    Text("Website").font(.system(size: 12))
                }
                .buttonStyle(LinkButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

struct PreferencePanes: View {
    
    @AppStorage("visualizerStyle") private var visualizerStyle = VisualizerStyle.gradient.rawValue
    @AppStorage("swipeToSeek") private var swipeToSeek = false
    
    @State private var dummy = false
    
    private var visualizers = ["None", "Gradient"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading) {
                        Text("General")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Toggle("Launch Jukebox on login", isOn: $dummy)
                        Toggle("Swipe to seek on trackpad (Experimental)", isOn: $swipeToSeek)
                    }
                    .padding()
                    .frame(width: geo.size.width, height: geo.size.height / 3, alignment: .topLeading)
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Menu Bar")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Toggle("Disable menu bar animation", isOn: $dummy)
                        Toggle("Disable menu bar marquee text", isOn: $dummy)
                        
                    }
                    .padding()
                    .frame(width: geo.size.width, height: geo.size.height / 3, alignment: .topLeading)
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Visualizer")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Picker("Style", selection: $visualizerStyle) {
                            ForEach(0..<visualizers.count) { index in
                                Text(visualizers[index]).tag(index)
                            }
                        }
                        .onChange(of: visualizerStyle) { val in
                            visualizerStyle = val
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
