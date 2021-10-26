//
//  JukeboxApp.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusBarItem: NSStatusItem!
    private var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let frameSize = NSSize(width: 400, height: 200)
        
        // Initialize ContentView
        let hostedContentView = NSHostingView(rootView: ContentView())
        hostedContentView.frame = NSRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        // Initialize Popover
        popover = NSPopover()
        popover.contentSize = frameSize
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = hostedContentView
        popover.contentViewController?.view.window?.makeKey()
        
        // Initialize Status Bar Item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Initialize the Status Bar Item Button properties
        if let statusBarItemButton = statusBarItem.button {
            
            // Change Status Bar Button title String attributes
            let trackDetails = "Track Title • Artist"
            let attributes = [ NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12) ]
            let attributedString = NSAttributedString(string: trackDetails, attributes: attributes)
            statusBarItemButton.attributedTitle = attributedString
            
            // Set Status Bar Item Button click action
            statusBarItemButton.action = #selector(togglePopover)
            
        }
        
        // TODO: Add observer to listen to when track changes to update the title in the menu bar
        
    }
    
    // Toggle open and close of popover
    @objc func togglePopover(_ sender: AnyObject?) {
        
        guard let statusBarItemButton = sender as? NSStatusBarButton else { return }
        
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: statusBarItemButton.bounds, of: statusBarItemButton, preferredEdge: .minY)
        }
        
    }
    
    // TODO: Function to update the track details of the Menu Bar Item
    
}

@main
struct JukeboxApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        
        // Required to hide window
        Settings {
            EmptyView()
        }
        
    }
    
}
