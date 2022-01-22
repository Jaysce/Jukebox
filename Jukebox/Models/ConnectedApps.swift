//
//  ConnectedApps.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 19/1/2022.
//

import Foundation
import SwiftUI

enum ConnectedApps: String, Equatable, CaseIterable {
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}
