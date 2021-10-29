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
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        
        self.titlebarAppearsTransparent = true
        self.level = .floating
        self.isReleasedWhenClosed = false
    }
    
}
