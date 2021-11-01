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
            
            // Add bar animation to Status Bar Item Button
            let barAnimation = StatusBarAnimation(backgroundColor: .white)
            let y = (statusBarItemButton.bounds.height - barAnimation.bounds.height) / 2
            barAnimation.setFrameOrigin(NSPoint(x: 0, y: y))
            barAnimation.autoresizingMask = [ .minYMargin, .maxYMargin ]
            statusBarItemButton.addSubview(barAnimation)
            
            // Change Status Bar Button title String attributes
            let trackDetails = ""
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
        
        // Add observer to listen for status bar appearance changes
        statusBarItem.addObserver(
            self,
            forKeyPath: "button.effectiveAppearance.name",
            options: [ .new, .initial ],
            context: nil)
        
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
        let titleAndArtist = "\(trackTitle) • \(trackArtist)"
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13, weight: .medium),
            NSAttributedString.Key.foregroundColor: NSColor.white.cgColor
        ]
        let attributedString = NSAttributedString(string: titleAndArtist, attributes: attributes)

        // Set the title of the Status Bar Item
        if let statusBarItemButton = statusBarItem.button {
            
            let containerHeight = statusBarItemButton.bounds.height
            let stringWidth = attributedString.width(containerHeight: containerHeight)
            
            // Remove old subviews to prepare for new track text
            statusBarItemButton.subviews.forEach({ $0.removeFromSuperview() })
            
            // Add bar animation to Status Bar Item Button
            let barAnimation = StatusBarAnimation(backgroundColor: .white)
            let y = (statusBarItemButton.bounds.height - barAnimation.bounds.height) / 2
            barAnimation.setFrameOrigin(NSPoint(x: 12, y: y))
            barAnimation.autoresizingMask = [ .minYMargin, .maxYMargin ]
            statusBarItemButton.addSubview(barAnimation)
            
            // If the track and artist title is short enough, shrink the button to fit contents
            if stringWidth < 200 {
                
                // Update manipulating image width with similar size as track string width
                let image = NSImage()
                image.size = NSSize(
                    width: attributedString.width(containerHeight: containerHeight) + 33,
                    height: statusBarItemButton.bounds.height)
                statusBarItemButton.image = image
                
                // Updated width of container after updating the manipulating image width
                let containerWidth = statusBarItemButton.bounds.width
                
                let marquee = MenuMarquee(
                    frame: NSRect(
                        x: 0,
                        y: 0,
                        width: containerWidth,
                        height: containerHeight),
                    text: attributedString,
                    start: true,
                    animation: .plain)
                
                marquee.setFrameOrigin(NSPoint(x: 0, y: y))
                marquee.autoresizingMask = [ .minYMargin, .maxYMargin, .minXMargin, .maxXMargin ]
                statusBarItemButton.addSubview(marquee)
                
            }
            
            // Otherwise the track and artist title is too long, so restrict button width to 250 and
            // start animated marquee text
            else {
                
                // Update manipulating image width with width of 250
                let image = NSImage()
                image.size = NSSize(width: 250, height: statusBarItemButton.bounds.height)
                statusBarItemButton.image = image
                
                // Updated width of container after updating the manipulating image width
                let containerWidth = statusBarItemButton.bounds.width
                                                
                let marquee1 = MenuMarquee(
                    frame: NSRect(
                        x: 0,
                        y: 0,
                        width: containerWidth,
                        height: containerHeight),
                    text: attributedString,
                    start: true)
                
                marquee1.setFrameOrigin(NSPoint(x: 12, y: y))
                marquee1.autoresizingMask = [ .minYMargin, .maxYMargin, .minXMargin, .maxXMargin ]
                statusBarItemButton.addSubview(marquee1)
                
                let marquee2 = MenuMarquee(
                    frame: NSRect(
                        x: 0,
                        y: 0,
                        width: containerWidth,
                        height: containerHeight),
                    text: attributedString,
                    start: false)
                
                marquee2.setFrameOrigin(NSPoint(x: stringWidth, y: y))
                marquee2.autoresizingMask = [ .minYMargin, .maxYMargin, .minXMargin, .maxXMargin ]
                statusBarItemButton.addSubview(marquee2)
                
            }

            statusBarItemButton.title = ""
            
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
    
    // Called when the status bar appearance is changed to update bar animation color
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "button.effectiveAppearance.name") {
            
            guard let oldBarAnimation = statusBarItem.button?.subviews[0] as? StatusBarAnimation else { return }
            let appearance = statusBarItem.button?.effectiveAppearance.name
            let frame = oldBarAnimation.frame
            
            switch appearance {
            case NSAppearance.Name.vibrantDark:
                let barAnimation = StatusBarAnimation(backgroundColor: .white)
                barAnimation.frame = frame
                statusBarItem.button?.replaceSubview(oldBarAnimation, with: barAnimation)
            default:
                let barAnimation = StatusBarAnimation(backgroundColor: .black)
                barAnimation.frame = frame
                statusBarItem.button?.replaceSubview(oldBarAnimation, with: barAnimation)
            }
            
        }
        
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
