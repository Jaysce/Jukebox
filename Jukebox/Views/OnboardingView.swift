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
    @AppStorage("connectedApp") private var connectedApp = ConnectedApps.spotify
    @State private var alertTitle = Text("Title")
    @State private var alertMessage = Text("Message")
    @State private var showingAlert = false
    @State private var onAppPicker = true
    @State private var continueDisabled = true
    
    private var name: Text {
        Text(connectedApp.localizedName)
    }
    
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
                    ZStack {
                        appPicker
                            .offset(x: onAppPicker ? 0 : -20)
                            .opacity(onAppPicker ? 1 : 0)
                            .animation(.spring(), value: onAppPicker)
                        details
                            .offset(x: onAppPicker ? 20 : 0)
                            .opacity(onAppPicker ? 0 : 1)
                            .animation(.spring(), value: onAppPicker)
                            .alert(isPresented: $showingAlert) {
                                Alert(title: alertTitle, message: alertMessage, dismissButton: .default(Text("Got it!")))
                    }
                    .disabled(!continueDisabled)
                    
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
                        if onAppPicker {
                            onAppPicker = false
                        } else {
                            NSApplication.shared.sendAction(#selector(AppDelegate.finishOnboarding), to: nil, from: nil)
                        }
                    }
                    .disabled(continueDisabled && !onAppPicker)
                    .keyboardShortcut(.defaultAction)
                }
                .frame(width: .infinity, height: 50)
            }
            .frame(width: 250, height: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
    
    var appPicker: some View {
        VStack {
            Text("Select the app you use")
                .font(.headline)
            Picker("", selection: $connectedApp) {
                ForEach(ConnectedApps.allCases, id: \.self) { value in
                    Text(value.localizedName).tag(value)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var details: some View {
        VStack {
            Text("""
                     Jukebox requires permission to control \(name) and display music data.
                     
                     Open \(name) and click 'Enable permissions' below and select OK in the alert that is presented.
                 """)
                .font(.caption2)
                .multilineTextAlignment(.center)
            Button("Enable permissions") {
                let consent = Helper.promptUserForConsent(for: connectedApp == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
                switch consent {
                case .closed:
                    alertTitle = Text("\(name) is not open")
                    alertMessage = Text("Please open \(name) to enable permissions")
                case .granted:
                    continueDisabled.toggle()
                    viewedOnboarding = true
                    return
                case .notPrompted:
                    return
                case .denied:
                    alertTitle = Text("Permission denied")
                    alertMessage = Text("Please go to System Preferences > Security & Privacy > Privacy > Automation, and check \(name) under Jukebox")
                }
                showingAlert = true
            }
        }
        
    }
}
