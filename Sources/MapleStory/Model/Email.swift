//
//  Email.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

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
    
    static let regularExpression = try! Regex("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+")
    
    static func validate(_ string: String) -> Bool {
        string.wholeMatch(of: regularExpression) != nil
    }
}

// MARK: - CustomStringConvertible

extension Email: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue.description
    }
    
    public var debugDescription: String {
        rawValue.debugDescription
    }
}
