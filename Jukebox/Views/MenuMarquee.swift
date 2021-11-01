//
//  MenuMarquee.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 1/11/21.
//

import Foundation
import AppKit

class MenuMarquee: NSView {
    
    enum MarqueeAnimationType {
        case plain, animated
    }
    
    init(frame frameRect: NSRect, text: NSAttributedString, start: Bool, animation: MarqueeAnimationType = .animated) {

        super.init(frame: NSRect(x: 0, y: 0, width: frameRect.width, height: frameRect.height))
        self.wantsLayer = true
        
        // Mask
        let mask = CALayer()
        mask.frame = CGRect(x: 12 + 26, y: 0, width: frameRect.width - 50, height: frameRect.height)
        mask.masksToBounds = true
        self.layer?.addSublayer(mask)

        // Text
        let textWidth = text.width(containerHeight: self.bounds.height)
        
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.frame = CGRect(
            x: (start ? 0 : textWidth),
            y: 1,
            width: textWidth + 16,
            height: self.bounds.height - 3)
        guard let backingScaleFactor = NSScreen.main?.backingScaleFactor else { return }
        textLayer.contentsScale = backingScaleFactor
        mask.addSublayer(textLayer)

        if animation == .plain { return }
        
        // Animation
        let duration = textWidth / 40
        let delay = 3.0
        
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = (start ? 0 : 16 + textWidth) + textLayer.bounds.width / 2
        animation.toValue = (start ? -textLayer.bounds.width + textLayer.bounds.width / 2  : 0 + textLayer.bounds.width / 2)
        animation.duration = duration
        animation.beginTime = delay
        
        let group = CAAnimationGroup()
        group.animations = [animation]
        group.duration = duration + delay
        group.repeatCount = .greatestFiniteMagnitude
        
        textLayer.add(group, forKey: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
