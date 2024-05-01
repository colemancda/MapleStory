//
//  Hair.swift
//
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation


/// MapleStory Hair
public struct Hair: RawRepresentable, Equatable, Hashable, Codable, Sendable {
    
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

public extension Hair {
    
    var color: Hair.Color {
        // TODO: Extract hair color
        fatalError()
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Hair: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Hair: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue.description
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - Definitions

public extension Hair {
    
    /// Toben Hair Style
    static func toben(_ color: Hair.Color) -> Hair {
        .init(rawValue: 30000 + numericCast(color.rawValue))
    }
    
    /// Rebel Hair Style
    static func rebel(_ color: Hair.Color) -> Hair {
        .init(rawValue: 30020 + numericCast(color.rawValue))
    }
    
    /// Rebel Hair Style
    static func buzz(_ color: Hair.Color) -> Hair {
        .init(rawValue: 30030 + numericCast(color.rawValue))
    }
    
    /// Rockstar Hair Style
    static func rockstar(_ color: Hair.Color) -> Hair {
        .init(rawValue: 30040 + numericCast(color.rawValue))
    }
    
    /// Metro Hair Style
    static func metro(_ color: Hair.Color) -> Hair {
        .init(rawValue: 30050 + numericCast(color.rawValue))
    }
    
    /// Catalyst Hair Style
    static func catalyst(_ color: Hair.Color) -> Hair {
        .init(rawValue: 30060 + numericCast(color.rawValue))
    }
}
