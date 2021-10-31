//
//  String+Dimensions.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 30/10/21.
//

import Foundation
import AppKit

extension String {
    
    func stringWidth(with font: NSFont) -> CGFloat {
        let attributes = [ NSAttributedString.Key.font: font ]
        return self.size(withAttributes: attributes).width
    }
    
    func stringHeight(with font: NSFont) -> CGFloat {
        let attributes = [ NSAttributedString.Key.font: font ]
        return self.size(withAttributes: attributes).height
    }
    
}
