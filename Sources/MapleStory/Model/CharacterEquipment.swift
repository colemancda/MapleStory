//
//  CharacterEquipment.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation

public extension Character {
    
    struct Equipment: Equatable, Hashable, Sendable {
        
        internal var elements: [Item]
        
        internal init(_ elements: [Item]) {
            self.elements = elements
        }
    }
}

// MARK: - CustomStringConvertible

extension Character.Equipment: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        elements.description
    }
    
    public var debugDescription: String {
        elements.description
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension Character.Equipment: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (UInt8, UInt32)...) {
        self.init(elements.map { Item(key: $0.0, value: $0.1) })
    }
}

// MARK: - Codable

extension Character.Equipment: Codable {
    
    public init(from decoder: Decoder) throws {
        let json = try String(from: decoder)
        try self.init(decodeJSON: json)
    }
    
    public func encode(to encoder: Encoder) throws {
        try encodeJSON().encode(to: encoder)
    }
}

internal extension Character.Equipment {
    
    static var encoder: JSONEncoder { JSONEncoder() }
    
    static var decoder: JSONDecoder { JSONDecoder() }
    
    init(decodeJSON json: String) throws {
        let elements = try Self.decoder.decode([Item].self, from: Data(json.utf8))
        self.init(elements)
    }
    
    func encodeJSON() throws -> String {
        let data = try Self.encoder.encode(elements)
        return String(data: data, encoding: .utf8)!
    }
}

// MARK: - Supporting Types

public extension Character.Equipment {
    
    struct Item: Equatable, Hashable, Codable, Sendable {
        
        public let key: UInt8
        
        public let value: UInt32
    }
}
