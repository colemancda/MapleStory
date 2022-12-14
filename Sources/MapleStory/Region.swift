//
//  Region.swift
//  
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

/// MapleStory Region
public struct Region: RawRepresentable, Equatable, Hashable, Codable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Region: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt8) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Region: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue.description
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - Definitions

public extension Region {
    
    /// GMS
    static var global: Region { 0x08 }
}
