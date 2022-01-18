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
    @State private var showingAppNotOpenAlert = false
    @State private var showingUserDeniedPermissionAlert = false
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
                        .alert(isPresented: $showingAppNotOpenAlert) {
                            Alert(title: Text("Spotify is not open"), message: Text("Please open Spotify to enable permissions"), dismissButton: .default(Text("Got it!")))
                        }
                    
                    Button("Enable permissions") {
                        _ = promptUserForConsent(for: Constants.Spotify.bundleID)
                    }
                    .disabled(!continueDisabled)
                    .alert(isPresented: $showingUserDeniedPermissionAlert) {
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
