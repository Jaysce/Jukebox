//
//  OnboardingWindow.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 3/1/2022.
//

import AppKit

class OnboardingWindow: NSWindow {
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 200),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = false
        self.level = .floating
    }
    
    deinit {
        print("Destroying onboarding window")
    }
    
}
