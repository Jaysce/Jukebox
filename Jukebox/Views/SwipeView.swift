//
//  SwipeView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 30/10/21.
//

import Foundation
import AppKit
import SwiftUI

protocol NSSwipeViewDelegate: AnyObject {
    
    func didSwipe(with event: NSEvent)
    
    func swipeEnded(with event: NSEvent)
    
}

class NSSwipeView: NSView {
    
    weak var delegate: NSSwipeViewDelegate!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handleSwipe(with event: NSEvent) {
        
        switch event.phase {
        case .ended:
            delegate.swipeEnded(with: event)
        default:
            delegate.didSwipe(with: event)
        }
        
    }
    
    override func scrollWheel(with event: NSEvent) {
        handleSwipe(with: event)
    }
    
}

struct SwipeView: NSViewRepresentable {
    
    @Binding var seekerPosition: Double
    let onEditingChanged: (Bool) -> Void
    
    func makeNSView(context: Context) -> NSSwipeView {
        let swipeView = NSSwipeView()
        swipeView.delegate = context.coordinator
        return swipeView
    }
    
    func updateNSView(_ nsView: NSSwipeView, context: Context) {}
    
}

extension SwipeView {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSSwipeViewDelegate {
        
        let parent: SwipeView
        
        init(_ parent: SwipeView) {
            self.parent = parent
        }
        
        func didSwipe(with event: NSEvent) {
            parent.onEditingChanged(true)
            parent.seekerPosition += event.deltaX
        }
        
        func swipeEnded(with event: NSEvent) {
            parent.onEditingChanged(false)
        }
        
    }
    
}
