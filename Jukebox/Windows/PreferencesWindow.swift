//
//  PreferencesWindow.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 29/10/21.
//

import Foundation
import AppKit

class PreferencesWindow: NSWindow {
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 232),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
        self.isReleasedWhenClosed = false
    }
    
}
