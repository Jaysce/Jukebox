//
//  OnboardingView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 3/1/2022.
//

import SwiftUI
import ScriptingBridge
import LaunchAtLogin

struct OnboardingView: View {

    @AppStorage("viewedOnboarding") var viewedOnboarding: Bool = false
    @State private var showingAlert1 = false
    @State private var showingAlert2 = false
    @State private var continueDisabled = true
    
    var body: some View {
        
        HStack(spacing: 0) {
            ZStack {
                MetalView(functionName: "warp", popoverIsShown: true)
                Image(nsImage: NSImage(named: "AppIcon")!)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(VisualEffectView(material: .popover, blendingMode: .withinWindow))
            }
            .frame(width: 250, height: .infinity)
            VStack(alignment: .center) {
                
                VStack {
                    Text("""
                             Jukebox requires permission to control Spotify and display music data.
                             
                             Open Spotify and click 'Enable permissions' below and select OK in the alert that is presented.
                         """)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .alert(isPresented: $showingAlert1) {
                            Alert(title: Text("Spotify is not open"), message: Text("Please open Spotify to enable permissions"), dismissButton: .default(Text("Got it!")))
                        }
                    
                    Button("Enable permissions") {
                        let spotifyApp: SpotifyApplication = SBApplication(bundleIdentifier: Constants.Spotify.bundleID)!
                        guard spotifyApp.isRunning else { showingAlert1 = true; return }
                        print(spotifyApp.currentTrack?.name ?? "No track")
                        
                        let target = NSAppleEventDescriptor(bundleIdentifier: Constants.Spotify.bundleID)
                        let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true)
                        if status == 0 {
                            continueDisabled.toggle()
                            viewedOnboarding = true
                        }
                        else if status == -1743 {
                            showingAlert2 = true
                        }
                    }
                    .disabled(!continueDisabled)
                    .alert(isPresented: $showingAlert2) {
                        Alert(title: Text("Permission denied"), message: Text("Please go to System Preferences > Security & Privacy > Privacy > Automation, and check Spotify under Jukebox"), dismissButton: .default(Text("Got it!")))
                    }
                    
                }
                .frame(width: .infinity, height: 150)
                .padding(.horizontal, 32)
                
                Divider()
                
                HStack {
                    Button("Quit") {
                        NSApplication.shared.terminate(self)
                    }
                    
                    Button("Continue") {
                        NSApplication.shared.sendAction(#selector(AppDelegate.finishOnboarding), to: nil, from: nil)
                    }
                    .disabled(continueDisabled)
                    .keyboardShortcut(.defaultAction)
                }
                .frame(width: .infinity, height: 50)
                
            }
            .frame(width: 250, height: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)

    }
}
