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
    @State private var showingAppNotOpenAlert = false
    @State private var showingUserDeniedPermissionAlert = false
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
                            .alert(isPresented: $showingAppNotOpenAlert) {
                                Alert(title: Text("\(name) is not open"), message: Text("Please open \(name) to enable permissions"), dismissButton: .default(Text("Got it!")))
                            }
                        details
                            .offset(x: onAppPicker ? 20 : 0)
                            .opacity(onAppPicker ? 0 : 1)
                            .animation(.spring(), value: onAppPicker)
                            .alert(isPresented: $showingUserDeniedPermissionAlert) {
                                Alert(title: Text("Permission denied"), message: Text("Please go to System Preferences > Security & Privacy > Privacy > Automation, and check \(name) under Jukebox"), dismissButton: .default(Text("Got it!")))
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
                _ = promptUserForConsent(for: connectedApp == .spotify ? Constants.Spotify.bundleID : Constants.AppleMusic.bundleID)
            }
        }
        
    }
    
    private func promptUserForConsent(for appBundleID: String) -> Bool {
        let target = NSAppleEventDescriptor(bundleIdentifier: appBundleID)
        let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true)
        
        switch status {
        case -600:
            print("The application with BundleID: \(appBundleID) is not open.")
            showingAppNotOpenAlert = true
            return false
        case -0:
            print("Permissions granted for the application with BundleID: \(appBundleID).")
            continueDisabled.toggle()
            viewedOnboarding = true
            return true
        case -1744:
            print("User consent required but not prompted for the application with BundleID: \(appBundleID).")
            return false
        default:
            print("The user has declined permission for the application with BundleID: \(appBundleID).")
            showingUserDeniedPermissionAlert = true
            return false
        }
    }
}
