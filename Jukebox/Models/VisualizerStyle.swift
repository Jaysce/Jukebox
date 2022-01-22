//
//  VisualizerStyle.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 6/11/21.
//

import Foundation
import SwiftUI

enum VisualizerStyle: String, Equatable, CaseIterable {
    case none = "None"
    case albumArt = "Artwork"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}
