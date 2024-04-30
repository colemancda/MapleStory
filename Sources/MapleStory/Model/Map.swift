//
//  Map.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

/// MapleStory Map Identifier
public struct Map: Equatable, Hashable, Codable, Identifiable, Sendable {
    
    public let id: ID
    
    public let name: String
    
    public let streetName: String
}

// MARK: - Supporting Types

public extension Map {
    
    /// MapleStory Map Identifier
    struct ID: RawRepresentable, Equatable, Hashable, Codable, Sendable {
        
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Map.ID: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Map.ID: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue.description
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - Constants

public extension Map.ID {
    
    
}
