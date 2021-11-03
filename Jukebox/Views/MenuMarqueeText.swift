//
//  MenuMarqueeText.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 3/11/21.
//

import AppKit
import SwiftUI

class MenuMarqueeText: NSView {
    
    // Invalidating Variables
    var text: String {
        didSet {
            self.needsDisplay = true
        }
    }
    
    var menubarIsDarkAppearance: Bool {
        didSet {
            self.needsDisplay = true
        }
    }
    
    var menubarBounds: NSRect {
        didSet {
            self.needsDisplay = true
        }
    }
    
    // Computed Properties
    private var foregroundColor: CGColor {
        menubarIsDarkAppearance ? NSColor.white.cgColor : NSColor.black.cgColor
    }
    
    // Constants
    let padding: CGFloat = 16
    
    // Properties
    private var maskLayer: CALayer!
    private var textLayer1: CATextLayer!
    private var textLayer2: CATextLayer!

    // Overrides
    override var wantsUpdateLayer: Bool {
        return true
    }
    
    init(text: String, menubarBounds: NSRect, menubarAppearance: NSAppearance) {
        
        self.text = text
        self.menubarBounds = menubarBounds
        self.menubarIsDarkAppearance  = menubarAppearance.name == .vibrantDark ? true : false
        super.init(frame: menubarBounds)
        self.wantsLayer = true
        
        // Mask
        self.maskLayer = setupMask()
        self.layer?.addSublayer(maskLayer)
        
        // Text
        self.textLayer1 = setupTextLayer(isFirstLayer: true)
        self.textLayer2 = setupTextLayer(isFirstLayer: false)
        maskLayer.addSublayer(textLayer1)
        maskLayer.addSublayer(textLayer2)
        
    }
    
    private func setupMask() -> CALayer {
        self.maskLayer = CALayer()
        self.maskLayer.frame = CGRect(x: 0, y: 0, width: menubarBounds.width, height: menubarBounds.height)
        maskLayer.masksToBounds = true
        return maskLayer
    }
    
    private func setupTextLayer(isFirstLayer: Bool) -> CATextLayer {
        let font = NSFont.systemFont(ofSize: 13, weight: .regular)
        let stringWidth = text.stringWidth(with: font) + padding
        let stringHeight = text.stringHeight(with: font)
                
        let textLayer = CATextLayer()
        textLayer.string = NSAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: foregroundColor
            ])
        
        textLayer.frame = CGRect(
            x: isFirstLayer ? 0 : stringWidth + padding,
            y: (menubarBounds.height / 2) - (stringHeight / 2),
            width: stringWidth,
            height: stringHeight)
        
        if let backingScaleFactor = NSScreen.main?.backingScaleFactor {
            textLayer.contentsScale = backingScaleFactor
        }
        
        if stringWidth - padding < 200 { return textLayer }
        
        let duration = stringWidth / 40
        let delay = 3.0
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = isFirstLayer ? 0 + stringWidth / 2 : stringWidth + stringWidth / 2
        animation.toValue = isFirstLayer ? -stringWidth + stringWidth / 2 : 0 + stringWidth / 2
        animation.duration = duration
        animation.beginTime = delay
        
        let group = CAAnimationGroup()
        group.animations = [animation]
        group.duration = duration + delay
        group.repeatCount = .greatestFiniteMagnitude
        textLayer.add(group, forKey: nil)
        
        return textLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateLayer() {
        
        self.frame = menubarBounds
        self.maskLayer.sublayers?.removeAll()
        self.maskLayer.frame = NSRect(x: 30, y: 0, width: menubarBounds.width - 30 - 8, height: menubarBounds.height)
                
        self.textLayer1 = setupTextLayer(isFirstLayer: true)
        self.textLayer2 = setupTextLayer(isFirstLayer: false)
        maskLayer.addSublayer(textLayer1)
        maskLayer.addSublayer(textLayer2)
        
    }
    
}
