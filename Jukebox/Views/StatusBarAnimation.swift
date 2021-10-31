//
//  StatusBarButton.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 31/10/21.
//

import Foundation
import AppKit

class StatusBarAnimation: NSView {
    
    init(backgroundColor: CGColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        self.wantsLayer = true
        
        for i in 0...4 {
            let bar = CALayer()
            bar.backgroundColor = backgroundColor
            bar.cornerRadius = 1
            bar.cornerCurve = .continuous
            bar.frame = CGRect(x: i * 3, y: 0, width: 2, height: 10)
            self.layer?.addSublayer(bar)
            
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.bounds))
            animation.fromValue = bar.bounds
            animation.toValue = CGRect(origin: .zero, size: CGSize(width: bar.bounds.width, height: 2))
            animation.duration = 0.4
            animation.autoreverses = true
            animation.repeatCount = .greatestFiniteMagnitude
            animation.beginTime = CACurrentMediaTime() - Double(i)
            bar.add(animation, forKey: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
