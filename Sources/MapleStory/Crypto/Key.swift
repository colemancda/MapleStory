//
//  Key.swift
//  
//
//  Created by Alsey Coleman Miller on 12/16/22.
//

import Foundation

public struct Key: Equatable, Hashable, Sendable {
    
    public let data: Data
    
    internal init(_ data: Data) {
        self.data = data
    }
}

public extension Key {
    
    /// Default key
    static var `default`: Key { Key(Data([0x13, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0xB4, 0x00, 0x00, 0x00, 0x1B, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00, 0x52, 0x00, 0x00, 0x00])) }
}

// MARK: - CustomStringConvertible

extension Key: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        data.toHexadecimal()
    }
    
    public var debugDescription: String {
        description
    }
}

// MARK: - Codable

extension Key: Codable {
    
    public init(from decoder: Decoder) throws {
        let data = try Data(from: decoder)
        self.init(data)
    }
    
    public func encode(to encoder: Encoder) throws {
        try data.encode(to: encoder)
    }
}
