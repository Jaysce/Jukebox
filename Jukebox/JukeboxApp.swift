//
//  JukeboxApp.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 13/10/21.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    private var statusBarItem: NSStatusItem!
    private var statusBarMenu: NSMenu!
    private var popover: NSPopover!
    private var preferencesWindow: PreferencesWindow!
    
    // MARK: - On Finish Launch
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let frameSize = NSSize(width: 400, height: 200)
        
        // Initialize ContentView
        @StateObject var contentViewVM = ContentViewModel()
        let hostedContentView = NSHostingView(rootView: ContentView(contentViewVM: contentViewVM))
        hostedContentView.frame = NSRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        // Initialize Popover
        popover = NSPopover()
        popover.contentSize = frameSize
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = hostedContentView
        popover.contentViewController?.view.window?.makeKey()
        
        // Initialize Status Bar Menu
        statusBarMenu = NSMenu()
        statusBarMenu.delegate = self
        let hostedAboutView = NSHostingView(rootView: AboutView())
        hostedAboutView.frame = NSRect(x: 0, y: 0, width: 220, height: 70)
        let aboutMenuItem = NSMenuItem()
        aboutMenuItem.view = hostedAboutView
        statusBarMenu.addItem(aboutMenuItem)
        statusBarMenu.addItem(NSMenuItem.separator())
        statusBarMenu.addItem(
            withTitle: "Check for updates...",
            action: nil,
            keyEquivalent: "")
        statusBarMenu.addItem(
            withTitle: "Preferences...",
            action: #selector(openPreferencesWindow),
            keyEquivalent: "")
        statusBarMenu.addItem(
            withTitle: "Quit Jukebox",
            action: #selector(NSApplication.terminate),
            keyEquivalent: "")
        
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
            statusBarItemButton.action = #selector(didClickStatusBarItem)
            statusBarItemButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
        }
        
        // Add observer to listen to when track changes to update the title in the menu bar
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatusBarItemTitle),
            name: NSNotification.Name("TrackChanged"),
            object: nil)
        
    }
    
    // MARK: - Handlers
    
    // Handle left or right click of Status Bar Item
    @objc func didClickStatusBarItem(_ sender: AnyObject?) {

        guard let event = NSApp.currentEvent else { return }
        
        switch event.type {
        case .rightMouseUp:
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(nil)
            
        default:
            togglePopover(statusBarItem.button)
        }
        
    }
    
    // Set menu to nil when closed so popover is re-enabled
    func menuDidClose(_: NSMenu) {
        statusBarItem.menu = nil
    }
    
    // Toggle open and close of popover
    @objc func togglePopover(_ sender: NSStatusBarButton?) {
        
        guard let statusBarItemButton = sender else { return }
        
        if popover.isShown {
            popover.performClose(statusBarItemButton)
        } else {
            popover.show(relativeTo: statusBarItemButton.bounds, of: statusBarItemButton, preferredEdge: .minY)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        
    }
    
    // Updates the title of the status bar with the currently playing track
    @objc func updateStatusBarItemTitle(_ notification: NSNotification) {

        // Get track data from notification
        guard let trackTitle = notification.userInfo?["title"] else { return }
        guard let trackArtist = notification.userInfo?["artist"] else { return }

        // Set the title of the Status Bar Item
        if let statusBarItemButton = statusBarItem.button {
            statusBarItemButton.title = "\(trackTitle) • \(trackArtist)"
        }
        
    }
    
    // Open the preferences window
    @objc func openPreferencesWindow(_ sender: AnyObject?) {
        
        if preferencesWindow == nil {
            preferencesWindow = PreferencesWindow()
            let hostedPrefView = NSHostingView(rootView: PreferencesView(parentWindow: preferencesWindow))
            preferencesWindow.contentView = hostedPrefView
        }
        
        preferencesWindow.center()
        preferencesWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
    }
    
}

// MARK: - SwiftUI App Entry Point

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
