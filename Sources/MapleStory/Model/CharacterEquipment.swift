//
//  CharacterEquipment.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import Collections

public extension Character {
    
    struct Equipment: Equatable, Hashable, Sendable {
        
        internal var elements: [Element]
        
        internal init(_ elements: [Element]) {
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
        self.init(elements.map { Element(key: $0.0, value: $0.1) })
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
        let elements = try Self.decoder.decode([Element].self, from: Data(json.utf8))
        self.init(elements)
    }
    
    func encodeJSON() throws -> String {
        let data = try Self.encoder.encode(elements)
        return String(data: data, encoding: .utf8)!
    }
}

// MARK: - Collection

extension Character.Equipment: Collection {
    
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    public var count: Int {
        elements.count
    }
    
    public func makeIterator() -> IndexingIterator<Self> {
        IndexingIterator(_elements: self)
    }
    
    public var startIndex: Int {
        elements.startIndex
    }
    
    public var endIndex: Int {
        elements.endIndex
    }
    
    public func index(after i: Int) -> Int {
        elements.index(after: i)
    }
    
    public subscript(index: Int) -> Character.Equipment.Element {
        elements[index]
    }
    
    public subscript(bounds: Range<Int>) -> Slice<Character.Equipment> {
        Slice(base: self, bounds: bounds)
    }
    
    public subscript(key: Element.Key) -> Element.Value? {
        elements.first(where: { $0.key == key })?.value
    }
}

// MARK: - Supporting Types

public extension Character.Equipment {
    
    struct Element: Equatable, Hashable, Codable, Sendable {
        
        public typealias Key = UInt8
        
        public typealias Value = UInt32
        
        public let key: Key
        
        public let value: Value
    }
}

// MARK: - Extensions

public extension Dictionary where Key == Character.Equipment.Element.Key, Value == Character.Equipment.Element.Value {
    
    
}
