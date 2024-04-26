//
//  Email.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import SwiftEmailValidator

/// Email
public struct Email: RawRepresentable, Equatable, Hashable, Codable, Sendable {
    
    public let rawValue: String
    
    public init?(rawValue: String) {
        guard Self.validate(rawValue) else {
            return nil
        }
        self.rawValue = rawValue
    }
}

internal extension Email {
    
    static func validate(_ string: String) -> Bool {
        EmailSyntaxValidator.correctlyFormatted(string, compatibility: .ascii)
    }
}

// MARK: - CustomStringConvertible

extension Email: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}
