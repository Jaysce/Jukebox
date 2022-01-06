//
//  StatusBarButton.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 31/10/21.
//

import Foundation
import AppKit

class StatusBarAnimation: NSView {
    
    // Invalidating Variables
    var menubarIsDarkAppearance: Bool {
        didSet {
            animate()
            self.needsDisplay = true
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            animate()
            self.needsDisplay = true
        }
    }
    
    // Computed Properties
    private var backgroundColor: CGColor {
        menubarIsDarkAppearance ? NSColor.white.cgColor : NSColor.black.cgColor
    }
    
    // Properties
    private var bars = [CALayer]()
    private var menubarHeight: Double
    
    // Overrides
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    let barHeights = [7.0, 6.0, 9.0, 8.0]
    let barDurations = [0.6, 0.3, 0.5, 0.7]
    
    init(menubarAppearance: NSAppearance, menubarHeight: Double, isPlaying: Bool) {
        self.menubarIsDarkAppearance = menubarAppearance.name == .vibrantDark ? true : false
        self.isPlaying = isPlaying
        self.menubarHeight = menubarHeight
        super.init(frame: CGRect(
            x: Constants.StatusBar.statusBarButtonPadding,
            y: 0,
            width: Constants.StatusBar.barAnimationWidth,
            height: menubarHeight))
        self.wantsLayer = true
        
        animate()
    }
    
    func animate() {
        self.layer?.sublayers?.removeAll()
        bars.removeAll()
        for i in 0..<barHeights.count {
            let bar = CALayer()
            bar.backgroundColor = backgroundColor
            bar.cornerRadius = isPlaying ? 1 : 2
            bar.cornerCurve = .continuous
            bar.anchorPoint = .zero
            bar.frame = CGRect(x: isPlaying ? Double(i) * 3.5 : Double(i) * 8, y: (menubarHeight / 2) - 5, width: isPlaying ? 2.0 : 6.0, height: isPlaying ? barHeights[i] : 10.0)
            self.layer?.addSublayer(bar)
            
            // Return early if not playing music
            if !isPlaying && i == 1 { return }
            if !isPlaying { continue }
            
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
            animation.fromValue = bar.bounds
            animation.toValue = CGRect(origin: .zero, size: CGSize(width: bar.bounds.width, height: 2))
            animation.duration = barDurations[i]
            animation.autoreverses = true
            animation.repeatCount = .greatestFiniteMagnitude
            animation.beginTime = CACurrentMediaTime() - Double(i)
            bar.add(animation, forKey: nil)
            bars.append(bar)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateLayer() {
        for bar in bars {
            bar.backgroundColor = backgroundColor
        }
    }
    
}
