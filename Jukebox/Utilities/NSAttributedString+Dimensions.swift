//
//  NSAttributedString+Dimensions.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 1/11/21.
//

import Foundation

extension NSAttributedString {
    
    func width(containerHeight: CGFloat) -> CGFloat {
        
        let rect = self.boundingRect(
            with: CGSize.init(
                width: CGFloat.greatestFiniteMagnitude,
                height: containerHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        
        return ceil(rect.size.width)
        
    }
    
    func height(containerWidth: CGFloat) -> CGFloat {
        
        let rect = self.boundingRect(
            with: CGSize.init(
                width: containerWidth,
                height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        
        return ceil(rect.size.height)
        
    }
    
}
