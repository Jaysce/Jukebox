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
            self.needsDisplay = true
        }
    }
    
    // Computed Properties
    private var backgroundColor: CGColor {
        menubarIsDarkAppearance ? NSColor.white.cgColor : NSColor.black.cgColor
    }
    
    // Properties
    private var bars = [CALayer]()
    
    // Overrides
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    let barHeights = [7.0, 6.0, 9.0, 8.0]
    let barDurations = [0.6, 0.3, 0.5, 0.7]
    
    init(menubarAppearance: NSAppearance, menubarHeight: Double) {
        self.menubarIsDarkAppearance = menubarAppearance.name == .vibrantDark ? true : false
        super.init(frame: CGRect(
            x: Constants.StatusBar.statusBarButtonPadding,
            y: 0,
            width: Constants.StatusBar.barAnimationWidth,
            height: menubarHeight))
        self.wantsLayer = true
        
        for i in 0..<barHeights.count {
            let bar = CALayer()
            bar.backgroundColor = backgroundColor
            bar.cornerRadius = 1
            bar.cornerCurve = .continuous
            bar.anchorPoint = .zero
            bar.frame = CGRect(x: Double(i) * 3.5, y: (menubarHeight / 2) - 5, width: 2.0, height: barHeights[i])
            self.layer?.addSublayer(bar)
            
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
