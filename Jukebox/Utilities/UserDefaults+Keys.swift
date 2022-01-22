//
//  UserDefaults+Keys.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 19/1/2022.
//

import Foundation

extension UserDefaults {
    @objc dynamic var connectedApp: String {
        return string(forKey: "connectedApp")!
    }
}
