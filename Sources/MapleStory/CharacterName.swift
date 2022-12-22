//
//  CharacterName.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

/// Character Name
public struct CharacterName: RawRepresentable, Equatable, Hashable, Codable, CustomStringConvertible, ExpressibleByStringLiteral {
    
    public let rawValue: String
    
    public init?(rawValue: String) {
        guard Self.validate(rawValue) else {
            return nil
        }
        self.rawValue = rawValue
    }
}

// MARK: - FixedLengthString

extension CharacterName: FixedLengthString {
    
    public static var length: Int { 13 }
}

// MARK: - Comparable

extension CharacterName: Comparable {
    
    public static func < (lhs: CharacterName, rhs: CharacterName) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func > (lhs: CharacterName, rhs: CharacterName) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}
