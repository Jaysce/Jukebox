//
//  NetworkError.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 27/10/21.
//

import Foundation

enum NetworkError: Error {
    case invalidURL(description: String?)
    case networkError(description: String?)
    case decodingFailed(description: String?)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL(let description):
            return description
        case .networkError(let description):
            return description
        case .decodingFailed(let description):
            return description
        }
    }
}
