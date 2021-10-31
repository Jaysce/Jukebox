//
//  MarqueeText.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 30/10/21.
//

import Foundation

import SwiftUI

struct MarqueeText: View {
    
    @ObservedObject private var contentViewVM: ContentViewModel
    private var font: NSFont
    private var delay: Double
    
    @State private var textWidth: CGFloat
    @State private var textHeight: CGFloat
    @State private var isAnimating = false
    @State private var viewID = 0
    
    init(contentViewVM: ContentViewModel, font: NSFont, delay: Double) {
        self.contentViewVM = contentViewVM
        self.font = font
        self.delay = delay
        
        textWidth = contentViewVM.track.title.stringWidth(with: font)
        textHeight = contentViewVM.track.title.stringHeight(with: font)
    }

    var body : some View {
        GeometryReader { geo in
            ZStack {
                Text(contentViewVM.track.title)
                    .font(Font(font))
                    .foregroundColor(.white).opacity(0.8)
                    .lineLimit(1)
                    .offset(x: self.isAnimating ? -textWidth - 16 : 0)
                    .fixedSize(horizontal: true, vertical: true)
                    .animation(.linear(duration: textWidth / 60).delay(delay).repeat(while: isAnimating))
                
                Text(contentViewVM.track.title)
                    .font(Font(font))
                    .foregroundColor(.black).opacity(0.8)
                    .lineLimit(1)
                    .offset(x: self.isAnimating ? 0 : textWidth + 16)
                    .fixedSize(horizontal: true, vertical: true)
                    .animation(.linear(duration: textWidth / 60).delay(delay).repeat(while: isAnimating))
                    .opacity(isAnimating ? 1 : 0)
            }
            .id(viewID)
            .onChange(of: contentViewVM.track.title, perform: { _ in
                self.textWidth = contentViewVM.track.title.stringWidth(with: font)
                self.textHeight = contentViewVM.track.title.stringHeight(with: font)
                if (textWidth > geo.size.width) {
                    self.isAnimating = true
                } else {
                    self.isAnimating = false
                }
            })
            .onAppear {
                print("APPEARED")
                print("Title: \(contentViewVM.track.title)")
                print(textWidth)
                print(textHeight)
                if (textWidth > geo.size.width) {
                    self.isAnimating = true
                } else {
                    self.isAnimating = false
                }
            }
        }
        .id(viewID)
        .frame(height: textHeight)
        .onTapGesture {
            self.viewID += 1
        }
    }
}

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = false) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}
